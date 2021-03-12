module DataTables
  class ActiveUser < DataTables::User
    delegate :params, :link_to, :content_tag, :admin_user_path,
              :edit_admin_user_path, :new_admin_user_order_path, :dom_id, to: :@view

    private

    def data
      records = []
      display_on_page.map do |record|
        records << [
          basic_fields(record),
          subscription_field(record),
          commited_field(record),
          action_links(record)
        ].flatten
      end
      records
    end

    private

    # ###################
    #  Specific Methods #
    # ###################

    def subscription_field(record)
      last_start_at = record.subscriptions.last.try(:start_at)
      "#{last_start_at} #{content_tag(:span, ActionController::Base.helpers.time_ago_in_words(last_start_at), class: "tag")}"
    end

    def commited_field(record)
      icon = content_tag :em, nil, class: "fa fa-lg #{ record.decorate.committed? ? 'fa-check-circle text-success' : 'fa-times-circle text-danger' }"
      sr_content = content_tag :span, class: 'sr-only' do
        record.decorate.committed?
      end
      icon + sr_content
    end

    def action_links(record)
      show_link = nil
      edit_link = nil

      show_link_text = I18n.t('admin.users.index.show_link')
      show_link = link_to admin_user_path(record.id), class: 'btn btn-default', title: show_link_text, id: dom_id(record, :show) do
        content_tag :em, nil, class: 'fa fa-eye', 'aria-label' => I18n.t('admin.users.index.show_link')
      end

      edit_link_text = I18n.t('admin.users.index.edit_link')
      edit_link = link_to edit_admin_user_path(record.id), class: 'btn btn-default', title: edit_link_text, id: dom_id(record, :edit) do
        content_tag :em, nil, class: 'far fa-edit', 'aria-label' => I18n.t('admin.users.index.edit_link')
      end

      new_order_link_text = I18n.t('admin.users.index.new_order_link')
      new_order_link = link_to new_admin_user_order_path(record.id), class: 'btn btn-default', title: new_order_link_text, id: dom_id(record, :new_order) do
        content_tag :em, nil, class: 'fa fa-shopping-cart', 'aria-label' => I18n.t('admin.users.index.new_order_link')
      end

      content_tag :div, class: 'btn-group btn-group-sm' do
        show_link + new_order_link + edit_link
      end
    end

    # ###################
    # DataTable Methods #
    # ###################

    def sort_order_filter
      records = users.order("#{sort_column} #{sort_direction}").includes(:subscriptions).references(:subscriptions)
      if params[:search].present? && params[:search][:value].present?
        records = records
                    .where("lower(users.firstname) LIKE :search_downcase OR \
                            lower(users.lastname) LIKE :search_downcase OR \
                            users.email LIKE :search OR \
                            CAST(subscriptions.start_at AS TEXT) LIKE :search",
                            search: "%#{params[:search][:value]}%",
                            search_downcase: "%#{params[:search][:value].downcase}%")
      end
      records
    end

    def sort_column
      columns = %w(users.lastname users.firstname users.email subscriptions.start_at subscriptions.commitment_period not_orderable)
      params[:order].present? ? columns[params[:order]['0'][:column].to_i] : columns[3]
    end
  end
end
