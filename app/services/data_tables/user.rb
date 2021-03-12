module DataTables
  class User
    delegate :params, :link_to, :content_tag, :admin_user_path,
              :edit_admin_user_path, :dom_id, to: :@view

    attr_reader :users

    def initialize(view, users)
      @view = view
      @users = users
    end

    def as_json
      {
        data: data,
        recordsTotal: users.count,
        recordsFiltered: sort_order_filter.count
      }
    end

    protected

    # What will be displayed in the DT.
    def data
      raise NoMethodError, "You have to implement private method 'data' with returns an array of fields."
    end

    def sort_order_filter
      raise NoMethodError, "You have to implement private method 'sort_order_filter' with returns an ActiveRelation collection."
    end

    def sort_column
      raise NoMethodError, "You have to implement private method 'sort_column' with returns the column name to sort upon."
    end

    def basic_fields(record)
      [record.lastname, record.firstname, record.email]
    end

    def display_on_page
      sort_order_filter.page(page).per(per_page)
    end

    def page
      params[:start].to_i / per_page + 1
    end

    def per_page
      params[:length].to_i > 0 ? params[:length].to_i : 25
    end

    def sort_direction
      if params[:order].present?
        params[:order]['0'][:dir] == 'desc' ? 'desc' : 'asc'
      else
        'desc'
      end
    end
  end
end
