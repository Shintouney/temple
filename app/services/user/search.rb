class User
  class Search
    attr_reader :criterias, :uesrs

    def initialize(criterias)
      @criterias = criterias
    end

    # Public: Processes the search of a user depending of criterias.
    #
    # @criterias[:between_age] = [age_min, age_max]
    # @criterias[:created_since] = [month_min, month_max]
    #
    # Returns a Array of User.
    def execute
      @users = User.all
      @users = add_filter(:between_age, @criterias["filter_between_age"].reject(&:blank?)) if @criterias["filter_between_age"].reject(&:blank?).present?
      @users = add_filter(:by_gender, @criterias["filter_gender"].reject(&:blank?)) if @criterias["filter_gender"].reject(&:blank?).present?
      @users = add_filter(:by_postal_code, @criterias["filter_postal_code"].reject(&:blank?)) if @criterias["filter_postal_code"].reject(&:blank?).present?
      @users = add_filter(:with_subscription, @criterias["filter_with_subscription"].reject(&:blank?)) if @criterias["filter_with_subscription"].reject(&:blank?).present?
      @users = add_filter(:created_since, @criterias["filter_created_since"].reject(&:blank?)) if @criterias["filter_created_since"].reject(&:blank?).present?
      @users = add_filter(:by_usual_room, @criterias["filter_usual_room"].reject(&:blank?)) if @criterias["filter_usual_room"].reject(&:blank?).present?
      @users = add_filter(:by_usual_activity, @criterias["filter_usual_activity"].reject(&:blank?)) if @criterias["filter_usual_activity"].reject(&:blank?).present?
      @users = add_filter(:by_booking_frequency, @criterias["filter_frequencies"].reject(&:blank?)) if @criterias["filter_frequencies"].reject(&:blank?).present?
      @users = add_filter(:by_last_booking_date, @criterias["filter_last_booking_dates"].reject(&:blank?)) if @criterias["filter_last_booking_dates"].reject(&:blank?).present?
      @users = add_filter(:by_last_visite_date, @criterias["filter_last_visite_dates"].reject(&:blank?)) if @criterias["filter_last_visite_dates"].reject(&:blank?).present?
      @users = add_filter(:by_last_article, @criterias["filter_last_article"].reject(&:blank?)) if @criterias["filter_last_article"].reject(&:blank?).present?
      @users
    end

    private


    def add_filter(filter_method_name, args)
      filtered_users = []
      args.each do |arg|
        filtered_users = (filtered_users + self.send(filter_method_name, arg)).uniq
      end
      filtered_users
    end

    def between_age(ages)
      ages = ages.tr('[]', '').split(',').map(&:to_i)
      @users.select {|user| user.birthdate.present? && user.birthdate > (Date.today - ages[1].years) && user.birthdate < (Date.today - ages[0].years)}
    end

    def by_gender(gender)
      @users.select {|user| user.gender == gender }
    end

    def by_gender_iteraction(gender)
      @users.select {|user| user.gender == gender }
    end

    def by_postal_code(postal_code)
      @users.select {|user| user.postal_code.present? && user.postal_code.match(/#{postal_code}/i) }
    end

    def with_subscription(subscription_plan_id)
      @users.select {|user| user.subscriptions.select{ |s|s.running? && s.subscription_plan.id == subscription_plan_id.to_i }.present? }
    end

    def created_since(ages)
      ages = ages.tr('[]', '').split(',').map(&:to_i)
      @users.select {|user| user.created_at > (Date.today - ages[1].months) && user.created_at < (Date.today - ages[0].months)}
    end

    def by_usual_room(room)
      @users.select { |user| user.lesson_bookings.present? && user.lesson_bookings.inject([]) { |a, e| (e.lesson.present? && e.lesson.room == room) ? a << e : a }.count >= 3 }
    end

    def by_usual_activity(usual_activity)
      @users.select do |user|
        user.lesson_bookings.present? && user.lesson_bookings.inject([]) { |a, e| (e.lesson.present? && e.lesson.activity == usual_activity) ? a << e : a }.count >= 3
      end
    end

    def by_booking_frequency(frequencies)
      frequencies = frequencies.tr('[]', '').split(',').map(&:to_i)
      @users.select do |user|
        nb_booking_last_month = user.lesson_bookings.where("created_at BETWEEN ? AND ?", Date.today - 1.months, Date.today).count
        nb_booking_last_month >= frequencies[0] && nb_booking_last_month <= frequencies[0]
      end
    end

    def by_last_booking_date(last_booking_dates)
      last_booking_dates = last_booking_dates.tr('[]', '').split(',').map(&:to_i)
      @users.select do |user|
        user.lesson_bookings.where("created_at BETWEEN ? AND ?", Date.today - last_booking_dates[1].days, Date.today - last_booking_dates[0].days).present?
      end
    end

    def by_last_visite_date(last_visite_dates)
      last_visite_dates = last_visite_dates.tr('[]', '').split(',').map(&:to_i)
      @users.select do |user|
        user.visits.where("created_at BETWEEN ? AND ?", Date.today - last_visite_dates[1].days, Date.today - last_visite_dates[0].days).present?
      end
    end

    def by_last_article(article_id)
      @users.select do |user|
        user.orders.joins(:order_items).where("order_items.product_type = 'Article' AND order_items.product_id = ?", article_id.to_i).present?
      end
    end
  end
end
