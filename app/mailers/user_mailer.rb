class UserMailer < ActionMailer::Base
  default Settings.mailer.default.to_hash

  layout "mail"

  def welcome(user_id)
    @user = User.find(user_id).decorate

    mail to: @user.email
  end

  def subscription_suspended(user_id, subscription_restart_date)
    @user = User.find(user_id)
    @restart_date = subscription_restart_date

    mail to: @user.email
  end

  def subscription_restart(user_id)
    @user = User.find(user_id)

    mail to: @user.email
  end

  def reset_password_email(user_id)
    @user = User.find(user_id).decorate

    mail to: @user.email
  end

  def invite_friend(user_id, to, text)
    @skip_signature = true
    @user = User.find(user_id).decorate
    @text = text

    mail to: '',
          bcc: to,
          reply_to: @user.email
  end

  def lesson_canceled(user_id, start_at, end_at, coach_name, activity)
    @user = User.find(user_id).decorate
    @start_at = I18n.l(start_at, format: "%e %B %H:%M")
    @end_at = I18n.l(end_at, format: "%H:%M")
    @coach_name = coach_name
    @activity = activity
    return if @start_at.present? && start_at < Time.now

    mail to: @user.email
  end

  def send_lesson_notification(lesson_id, user_id)
    @user = User.find(user_id)
    @lesson = Lesson.find(lesson_id).try(:decorate)
    return unless @lesson.upcoming?

    mail to: @user.email, subject: default_i18n_subject( date: I18n.l(@lesson.start_at, format: "%d/%m") )
  end

  def lesson_booking_confirmation(user_id, lesson_id)
    @user = User.find(user_id).decorate
    @lesson = Lesson.find(lesson_id)
    return unless @lesson.upcoming?

    mail to: @user.email, subject: default_i18n_subject(location: I18n.t("location.#{@lesson.location}"),
                                                        date: I18n.l(@lesson.start_at, format: "%d/%m/%y"),
                                                        start_at: I18n.l(@lesson.start_at, format: '%H:%M'),
                                                        end_at: I18n.l(@lesson.end_at, format: '%H:%M'))
  end

  def send_ical_invite(user_id, lesson_id, path_to_ics_file, require_ics)
    @user = User.find(user_id).decorate
    @lesson = Lesson.find(lesson_id)
    return unless @lesson.upcoming?

    begin
      @cal = File.read(path_to_ics_file)
    rescue
      require_ics = false
    end
    @require_ics = require_ics

    email = mail to: @user.email, subject: default_i18n_subject(location: I18n.t("location.#{@lesson.location}"),
                                                                date: I18n.l(@lesson.start_at, format: "%A %d/%m"))
    add_ical_part_to(email) if require_ics
    email
  end

  private
  def add_ical_part_to(mail)
    outlook_body = @cal
    mail.add_part(Mail::Part.new do
      content_type "text/calendar; method=REQUEST"
      body outlook_body
    end)
  end
end
