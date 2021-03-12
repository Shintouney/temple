module DataTables
  class RedListUser < DataTables::User

    private

    def data
      records = []
      display_on_page.map do |record|
        records << [
          basic_fields(record),
          last_subscription_fields(record),
          last_payments_fields(record),
          retries_count(record),
          comment(record),
          format('%#.02f', record.invoices.with_states([:pending_payment, :pending_payment_retry]).sum(:total_price_ati)),
          action_links(record)
        ].flatten
      end
      records
    end

    private

    # ###################
    #  Specific Methods #
    # ###################

    def last_payments_fields(record)
      [date_for_object(last_payment(record, :accepted), :created_at),
      date_for_object(last_payment(record, :declined), :created_at)]
    end

    def last_subscription_fields(record)
      [record.subscriptions.last.try(:start_at),
      record.subscriptions.last.try(:decorate).try(:commitment_period)]
    end

    def comment(record)
      payment = last_payment(record, :declined)
      return if payment.nil?
      payment.comment
    end

    def retries_count(record)
      payment = last_payment(record, :declined)
      return if payment.nil?
      payment.invoices.last.payments.with_state(:declined).count
    end

    def date_for_object(record, column)
      record[column].strftime("%d/%m/%y") if record.present?
    end

    def last_payment(record, state)
      record.payments.with_state(state).last
    end

    def action_links(record)
      first_link = nil
      second_link = nil

      show_link_text = I18n.t('admin.users.index.show_link')
      first_link = link_to admin_user_path(record.id), class: 'btn btn-default', title: show_link_text, id: dom_id(record, :show) do
        content_tag :em, nil, class: 'fa fa-eye', 'aria-label' => I18n.t('admin.users.index.show_link')
      end

      edit_link_text = I18n.t('admin.users.index.edit_link')
      second_link = link_to edit_admin_user_path(record.id), class: 'btn btn-default', title: edit_link_text, id: dom_id(record, :edit) do
        content_tag :em, nil, class: 'far fa-edit', 'aria-label' => I18n.t('admin.users.index.edit_link')
      end

      content_tag :div, class: 'btn-group btn-group-sm' do
        first_link + " " + second_link
      end
    end

    # ###################
    # DataTable Methods #
    # ###################

    def sort_order_filter
      records = users.order("#{sort_column} #{sort_direction}").includes(:subscriptions, invoices: :payments).references(:subscriptions, invoices: :payments)
      if params[:search].present? && params[:search][:value].present?
        records = records
                    .where("lower(users.firstname) LIKE :search_downcase OR \
                            lower(users.lastname) LIKE :search_downcase OR \
                            users.email LIKE :search OR \
                            CAST(subscriptions.start_at AS TEXT) LIKE :search OR \
                            payments.comment LIKE :search OR \
                            CAST(payments.created_at AS TEXT) LIKE :search",
                            search: "%#{params[:search][:value]}%",
                            search_downcase: "%#{params[:search][:value].downcase}%")
      end
      records
    end

    def sort_column
      columns = %w(users.lastname users.firstname users.email subscriptions.start_at
                   not_orderable not_orderable not_orderable not_orderable payments.comment not_orderable)
      params[:order].present? ? columns[params[:order]['0'][:column].to_i] : columns[1]
    end
  end
end
