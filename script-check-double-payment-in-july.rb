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
target_users_ids = User.active.pluck(:id)
ignore_users_ids = User.where("email LIKE ? OR email LIKE ?", "%@tsc.digital", "%@temple-nobleart.fr").pluck(:id)
ignore_users_ids = ignore_users_ids.compact.uniq

# Offset to start scan
offset_begin = Time.parse("2019-07-04").strftime("%Y-%m-04")

# Fetch users active
payments = Payment.where(state: "accepted").where("payments.created_at >= ?", offset_begin)
payments = payments.where(user_id: target_users_ids) if target_users_ids.present?
payments = payments.where.not(user_id: ignore_users_ids) if ignore_users_ids.present?
#payments = payments.limit(4)

# Output variables
issues = {}
total_amount_due = 0
total_people_concerned = 0
payments_count = payments.size
progress_bar = ProgressBar.new(payments_count, "Payments")

# Iterate through users by batch of 100
payments.each do |payment|
  next unless payment.invoices.map(&:order_items).detect { |_| _.pluck(:product_type, :product_price_ati).detect { |product_type, product_price_ati| product_type == "SubscriptionPlan" && product_price_ati != 0 } }
  order_item_subscription_name = nil
  payment.invoices.map(&:order_items).each do |order_items| 
    order_items.each do |order_item|
      if order_item.product_type == "SubscriptionPlan" && order_item.product_price_ati != 0
        order_item_subscription_name = order_item.product_name
        break
      end
    end
  end
  next if !order_item_subscription_name.present?
  issues[payment[:user_id]] ||= []
  issues[payment[:user_id]] << {
    created_at: payment.created_at,
    price: payment.price,
    name: order_item_subscription_name,
    user_firstname: payment.user.firstname,
    user_lastname: payment.user.lastname,
    profile_url: "https://membres.temple-nobleart.fr/admin/users/#{payment[:user_id]}/orders",
  }
  progress_bar.increment
end

puts ""
puts "#" * 120
issues = issues.compact
issues.each do |user_id, issues_row|
  begin
    next if issues_row.size < 2
    next if !issues_row.detect { |issue| issue[:created_at].strftime("%Y-%m-%d") == "2019-07-04" && issue[:price] >= 49.99 }
    # puts "\n##{total_people_concerned + 1}"
    # puts "#{issues_row[0][:profile_url]}"
    issues_row = issues_row.sort_by { |issue| issue[:price] }
    issues_row.each do |issue|
      # puts "#{I18n.l(issue[:created_at])}\t#{issue[:price]} euros\t(#{issue[:name]})"
      total_amount_due += issue[:price]
    end
    # puts "Montant remboursement:\t#{issues_row[0][:price]} euros"
    puts "#{issues_row[0][:price]}\t|#{issues_row[0][:user_firstname]}|#{issues_row[0][:user_lastname]}"
    total_people_concerned += 1
  rescue => exception
    puts "------- ISSUE :"
    puts issues_row
    puts "------- EXCEPTION :"
    puts exception.message
    puts exception.backtrace
    puts "-------"
  end
end
puts ""
puts "#" * 120
puts ""
puts "Money to charge: [#{total_amount_due.to_s}€]"
puts "People concerned: #{total_people_concerned}"
puts "Membre actifs total: #{target_users_ids.size}"
puts ""
puts "#" * 120

