class UserDecorator < Draper::Decorator
  delegate_all

  decorates_association :orders
  decorates_association :current_subscription
  decorates_association :sponsor
  decorates_association :sponsored_users

  DEFAULT_USER_PROFILE_IMAGE_NAME = 'default-user-profile-image.jpg'
  CURRENT_ORDERS_LIMIT = 10

  # Public: The formatted name of the User.
  #
  # Returns a String.
  def full_name
    "#{firstname} #{lastname}"
  end

  # Public: The UserImage of the user selected for its profile picture
  # or a default placeholder image.
  #
  # Returns a HTML img tag String.
  def profile_image_thumbnail
    image_path = profile_user_image.present? ? profile_user_image.image.url(:thumbnail) :
                                                DEFAULT_USER_PROFILE_IMAGE_NAME

    h.image_tag image_path, class: 'img-thumbnail', alt: full_name
  end

  # Public: The UserImage of the user selected for its profile picture miniature
  # or a default placeholder image.
  #
  # Returns a HTML img tag String.
  def profile_image_miniature
    image_path = profile_user_image.present? ? profile_user_image.image.url(:miniature) :
                                                DEFAULT_USER_PROFILE_IMAGE_NAME

    h.image_tag image_path, class: 'img-thumbnail', alt: full_name
  end

  # Public: The decorated current active SubscriptionPlan for the user.
  #
  # Returns a SubscriptionPlanDecorator object or nil.
  def current_subscription_plan
    return @current_subscription_plan if @current_subscription_plan

    if @current_subscription_plan = current_subscription.try(:subscription_plan)
      @current_subscription_plan = SubscriptionPlanDecorator.decorate(@current_subscription_plan)
    end
  end

  # Public: A collection of SubscriptionPlan that can be chosen
  # when replacing the user subscription.
  #
  # Returns a collection of SubscriptionPlan records.
  def updatable_subscription_plans
    subscription_plans = SubscriptionPlan.where(disabled: false).order(:name)

    if current_subscription_plan.present?
      subscription_plans.where('id != ?', current_subscription_plan.id)
    else
      subscription_plans
    end
  end

  # Public: A limited, decorated collection of decorated Order records for the user
  # created in the current month.
  #
  # Returns a collection of OrderDecorator objects.
  def current_orders
    @current_orders ||= OrderDecorator.decorate_collection(
                          object.
                            orders.
                            includes(:order_items).
                            from_current_month.
                            limit(CURRENT_ORDERS_LIMIT).
                            order(:created_at))
  end

  # Public: The total count of the orders created this month for the user.
  #
  # Returns an Integer.
  def current_month_orders_count
    @current_month_orders_count ||= object.orders.from_current_month.count
  end

  # Public: A limited, decorated collection of the latest Order records for the user.
  # Records are ordered by their creation date with the last order being first.
  #
  # Returns a collection of OrderDecorator objects.
  def latest_orders
    @latest_orders ||= OrderDecorator.decorate_collection(
                          object.
                            orders.
                            includes(:order_items).
                            order('created_at DESC').
                            limit(3))
  end

  # Public: The last Payment record linked to the User.
  #
  # Returns a Payment object or nil.
  def last_payment
    @last_payment ||= payments.order(:created_at).last
  end

  # Public: Fetch the next LessonBooking for the user.
  #
  # Returns a LessonBooking record or nil.
  def next_lesson_booking
    return @next_lesson_booking if @next_lesson_booking

    next_lesson_booking = user.lesson_bookings.upcoming.order('lessons.start_at').first
    @next_lesson_booking = LessonBookingDecorator.decorate(next_lesson_booking) if next_lesson_booking
  end

  # Public: The started_at date of the last (ended) visit.
  #
  # Returns a String.
  def last_visit_started_at
    last_visit = user.visits.ended.order(:started_at).last

    last_visit ? I18n.l(last_visit.started_at.to_date) : "/"
  end

  # Public: The created_at date of the last (failed) payments.
  #
  # Returns a String.
  def last_failed_payment_created_at
    last_failed_payment = payments.with_state(:declined).order(:created_at).last

    last_failed_payment ? I18n.l(last_failed_payment.created_at.to_date) : ""
  end

  # Public: The created_at date of the last lesson bookings.
  #
  # Returns a String.
  def last_lesson_booking_created_at
    last_lesson_booking = lesson_bookings.order(:created_at).last

    last_lesson_booking ? I18n.l(last_lesson_booking.created_at.to_date) : ""
  end

  # Public: The reason date of the last (failed) payments.
  #
  # Returns a String.
  def last_failed_payment_reason
    last_failed_payment = payments.with_state(:declined).order(:created_at).last

    last_failed_payment && last_failed_payment.comment.present? ? last_failed_payment.comment : ""
  end

  # Public: The reason date of the last (failed) payments.
  #
  # Returns a String.
  def last_subscription_name
    last_subscription = subscriptions.includes(:subscription_plan).order(:created_at).last

    last_subscription ? last_subscription.subscription_plan.name : ""
  end

  # Public: A link tag to use when displaying autocomplete data for a User.
  #
  # Returns a String.
  def autocomplete_link
    h.link_to '#' do
      h.content_tag :div, class: 'row' do
        h.content_tag(:div, profile_image_thumbnail, class: 'col-sm-2').html_safe +
        h.content_tag(
          :div,
          "#{full_name} #{h.tag(:br)} #{I18n.t('user.decorator.last_visit')} #{last_visit_started_at}".html_safe,
          class: 'col-sm-10'
        ).html_safe
      end
    end
  end

  def address
    "#{object.street1} #{object.street2}"
  end

   def full_address
    h.content_tag(:div, address) + h.content_tag(:div, "#{object.postal_code} #{object.city}")
  end

  # Public: Build a Hash of required data to use as an autocomplete JSON response.
  #
  # Returns a Hash.
  def as_json_for_autocomplete
    {id: id, value: full_name, link: autocomplete_link}
  end
end
