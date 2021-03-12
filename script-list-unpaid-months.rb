class ProgressBar
  def initialize(total, description)
    @description = description
    @total = total
    @counter = 1
  end

  def increment
    complete = sprintf("%#.2f %", ((@counter.to_f / @total.to_f) * 100))
    print "\r\e[0K#{@description} #{@counter}/#{@total} (#{complete})"
    @counter += 1
  end
end

# Custom users
users_ids = [].compact.uniq
ignore_users_ids = [].compact.uniq

# Offset to start scan
offset_begin = Time.parse("2019-01-01").strftime("%Y-%m-01")

# Fetch users active
db_users = User.active.includes(:invoices)
db_users = db_users.where(id: users_ids) if users_ids.present?
db_users = db_users.where.not(id: ignore_users_ids) if ignore_users_ids.present?
db_users = db_users.uniq

# Output variables
issues = []
total_amount_due = 0
users_count = db_users.size
progress_bar = ProgressBar.new(users_count, "Users")

# Iterate through users by batch of 100
db_users.find_in_batches(batch_size: 100) do |row_users|
  row_users.each do |user|
    next if user.email.include?("@temple-nobleart.fr") || user.email.include?("@tsc.digital")
    invoices_data = user.invoices.where.not(state: "canceled").where("invoices.end_at >= ?", offset_begin).order(end_at: :asc).map do |invoice|
      invoice_data = {
        _end_at: invoice.end_at,
        end_at: invoice.end_at.beginning_of_month,
        subscription_plan_ids: invoice.order_items.select { |order_item| order_item.product_type == "SubscriptionPlan" }.map(&:product_id),
      }
      invoice_data
    end.compact.select { |invoice_data| invoice_data[:subscription_plan_ids].present? }
    invoices_data.each.with_index(0) do |_, j|
      d1 = invoices_data[j]
      d2 = invoices_data[j + 1]
      next if d2.nil?
      next if !d1[:subscription_plan_ids].present? && !d2[:subscription_plan_ids].present?
      if d2.present?
        gap_days = (d2[:end_at] - d1[:end_at]).to_i
        if gap_days > 32
          if d2[:subscription_plan_ids].present?
            subscription_plan_ids = d2[:subscription_plan_ids]
          else
            subscription_plan_ids = d1[:subscription_plan_ids]
          end
          issue_month = d1[:end_at].advance(months: 1)
          next_date = d1[:_end_at] + 1.month
          if (Date.today.month == 1 && d1[:_end_at].day >= 29) || d1[:_end_at].day == 31
            planning_payment_date = next_date.end_of_month - 1.day
          else
            planning_payment_date = Date.new(next_date.year, next_date.month, d1[:_end_at].day)
          end
          product_ids = []
          issues << { 
            user_id: user.id,
            month: issue_month.strftime("%B %Y"),
            profile_url: "https://membres.temple-nobleart.fr/admin/users/#{user.id}/invoices",
            previous_date: d1[:_end_at],
            planning_payment_date: planning_payment_date,
            subscription_plan_ids: subscription_plan_ids,
            gap_days: gap_days,
          }
          break
        end
      end
    end
    progress_bar.increment
  end
end

puts ""
puts "#" * 120
issues_grouped = issues.group_by { |issue| issue[:month] }
issues_grouped.each do |month, issues_group|
  puts "\n[#{month}]"
  issues_group.each do |issue|
    begin
      amount_issue = SubscriptionPlan.where(id: issue[:subscription_plan_ids]).map(&:price_ati).sum
      next if amount_issue <= 0
      puts "#{issue[:profile_url]} #{amount_issue}e (#{issue[:gap_days]})"
      user = User.find(issue[:user_id])
      # if user.invoices.where(state: :pending_payment, next_payment_at: issue[:planning_payment_date], end_at: issue[:planning_payment_date]).exists?
      #   puts "Invoice already planned for charging"
      #   next
      # end
      total_amount_due += amount_issue
      # deferred_invoice = user.invoices.build(
      #   start_at: issue[:previous_date],
      #   end_at: issue[:planning_payment_date],
      #   subscription_period_start_at: issue[:previous_date] + Subscription::PERIODICITY,
      #   subscription_period_end_at: issue[:planning_payment_date] + Subscription::PERIODICITY,
      #   next_payment_at: issue[:planning_payment_date],
      #   state: :pending_payment,
      # )
      # deferred_invoice.copy_user_attributes
      # ActiveRecord::Base.transaction do
      #   deferred_invoice.save!  
      #   order = Order.create!(user: user, invoice: deferred_invoice, direct_payment: false)
      #   issue[:subscription_plan_ids].each do |subscription_plan_id|
      #     Order::AddProduct.new(order, SubscriptionPlan.find(subscription_plan_id)).execute
      #   end
      #   result = order.persisted? && order.order_items.size == issue[:subscription_plan_ids].size
      #   raise ActiveRecord::Rollback unless result
      #   order.save!
      #   deferred_invoice.compute_total_price
      #   deferred_invoice.save!
      # end
    rescue => exception
      puts "------- ISSUE :"
      puts issue
      puts "------- EXCEPTION :"
      puts exception.message
      puts exception.backtrace
      puts "-------"
    end
  end
end
puts "Money to charge: [#{total_amount_due.to_s}€]"
puts "Matched users:   [#{issues.size}]"
puts ""
puts "#" * 120

