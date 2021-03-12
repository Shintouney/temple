module Admin::LessonTemplatesHelper
  # Public: the localized week days names
  # and their values (with monday being 1 and sunday being 7)
  # for use as options in a select tag.
  #
  # Returns an Array.
  def weekdays_options
    1.upto(7).map do |day|
      [I18n.t('date.day_names')[day % 7], day]
    end
  end
end
