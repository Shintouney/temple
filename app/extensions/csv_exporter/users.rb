# encoding: UTF-8
include ActionView::Helpers::NumberHelper
require 'fileutils'

module CSVExporter
  class Users < Base

    def initialize(export)
      @export = export
    end

    def execute
      csv_string = ""
      FileUtils.mkdir_p 'tmp/exports'
      begin
        @elements_to_csv = UserDecorator.decorate_collection(@export.users)
        csv_string = CsvShaper::Shaper.encode do |csv_content|
          if @export.subtype == "reporting"
            reporting_headers(csv_content)
            reporting_rows(csv_content)
          else
            headers(csv_content)
            rows(csv_content)
          end
        end
        File.open(@export.path, 'w') { |file| file.write("\xEF\xBB\xBF" + csv_string) }
        @export.complete!
      rescue StandardError => e
        ap e
        @export.destroy
        Raven.capture_exception(e)
      ensure
        @export.progress_tracker.delete
      end
      csv_string
    end

    private

      USER_COLUMNS = [
        :id,
        :email,
        :created_at,
        :last_subscription_end_at,
        :commitment_period_end_at,
        :origin_location,
        :firstname,
        :lastname,
        :street1,
        :street2,
        :postal_code,
        :city,
        :billing_name,
        :billing_address,
        :phone,
        :payment_mode,
        :birthdate,
        :gender,
        :card_reference,
        :sponsor_id,
        :facebook_url,
        :linkedin_url,
        :professional_sector,
        :position,
        :company,
        :professional_address,
        :professional_zipcode,
        :professional_city,
        :education,
        :heard_about_temple_from,
        :last_visit,
        :last_booking
      ]

      PROFILE_COLUMNS = [
        :sports_practiced,
        :attendance_rate,
        :fitness_goals,
        :boxing_disciplines_practiced,
        :boxing_level,
        :boxing_disciplines_wished,
        :attendance_periods,
        :weekdays_attendance_hours,
        :weekend_attendance_hours,
        :transportation_means
      ]

      REPORTING_USER_COLUMNS = {
        email: "E-mail",
        id: "Identifiant",
        created_at: "Date de création",
        end_of_last_subscription: "Date de fin d'abonnement",
        sponsor: "Parrainé par",
        origin: "Origine de l'inscription",
        firstname: "Prénom",
        lastname: "Nom",
        street: "Adresse",
        postal_code: "Code postal",
        city: "Ville",
        country_code: "Pays",
        birthdate: "Date de naissance",
        gender: "Civilité",
        last_visit: "Last visit",
        last_lesson_booking: "Last booking",
        last_subscription_name: "Nom de l'abonnement",
        count_failed_payment: "Nombres d’échecs",
        last_failed_payment_amount_due: "Sommes non payées",
        last_failed_payment_created_at: "Date du dernier paiement échoué",
        last_failed_payment_reason: "Raison du dernier paiement échoué",
        state: "State",
      }.freeze
    
    def reporting_headers(csv)
      csv.headers do |csv_header|
        csv_header.columns(*(REPORTING_USER_COLUMNS.keys))
        csv_header.mappings(REPORTING_USER_COLUMNS)
      end
    end

    def reporting_rows(csv)
      csv.rows elements_to_csv do |csv_row, user|
        csv_row.cell :email, user.email
        csv_row.cell :id, user.id
        csv_row.cell :created_at, I18n.l(user.created_at)
        if user.current_subscription.present?
          csv_row.cell :end_of_last_subscription, user.current_subscription.decorate.commitment_period
        else
          csv_row.cell :end_of_last_subscription, user.subscriptions.last.try(:decorate).try(:end_at).try(:commitment_period)
        end
        csv_row.cell :sponsor, user.sponsor.present? ? user.sponsor.decorate.full_name : nil
        csv_row.cell :origin, user.subscriptions.last.try(:origin_location)
        csv_row.cell :firstname, user.firstname
        csv_row.cell :lastname, user.lastname
        csv_row.cell :street, user.address
        csv_row.cell :postal_code, user.postal_code
        csv_row.cell :city, user.city
        csv_row.cell :country_code, user.country_code
        csv_row.cell :birthdate, user.birthdate
        csv_row.cell :gender, user.gender
        csv_row.cell :last_visit, user.last_visit_started_at
        csv_row.cell :last_lesson_booking, user.last_lesson_booking_created_at
        csv_row.cell :last_subscription_name, user.subscriptions.last.try(:subscription_plan).try(:name)

        _deferred_invoice_failed = user.current_deferred_invoice
        if _deferred_invoice_failed.present? && _deferred_invoice_failed.pending_payment_retry?
          csv_row.cell :count_failed_payment, _deferred_invoice_failed.payments.size
          csv_row.cell :last_failed_payment_amount_due, _deferred_invoice_failed.payments.last.try(:total_price_ati) || 0
        else
          csv_row.cell :count_failed_payment, 0
          csv_row.cell :last_failed_payment_amount_due, 0
        end
        csv_row.cell :last_failed_payment_created_at, user.last_failed_payment_created_at
        csv_row.cell :last_failed_payment_reason, user.last_failed_payment_reason
        csv_row.cell :state, user.subscriptions.where(state: [:running, :temporarily_suspended]).any? ? "ACTIF" : 'INACTIF'
        @export.progress_tracker.increment_processed_items
      end
    end

    def headers(csv)
      csv.headers do |csv_header|
        csv_header.columns(*USER_COLUMNS + PROFILE_COLUMNS)
        csv_header.mappings Hash[
            USER_COLUMNS.map { |column_name| [column_name, User.human_attribute_name(column_name)] } +
            PROFILE_COLUMNS.map { |column_name| [column_name, Profile.human_attribute_name(column_name)] }
          ]
      end
    end

    def rows(csv)
      csv.rows elements_to_csv do |csv_row, user|
        csv_row.cells :id,
                  :email,
                  :firstname,
                  :lastname,
                  :street1,
                  :street2,
                  :postal_code,
                  :city,
                  :billing_name,
                  :billing_address,
                  :phone,
                  :payment_mode,
                  :card_reference,
                  :facebook_url,
                  :linkedin_url,
                  :professional_sector,
                  :position,
                  :company,
                  :professional_address,
                  :education,
                  :heard_about_temple_from,
                  :professional_zipcode,
                  :professional_city
        csv_row.cell :created_at, I18n.l(user.created_at)

        csv_row.cell :last_visit, I18n.l(user.visits.last.created_at) if user.visits.present?
        csv_row.cell :last_booking, I18n.l(user.lesson_bookings.last.created_at) if user.lesson_bookings.present?

        map_subscriptions(csv_row, user)

        csv_row.cell :birthdate, I18n.l(user.birthdate) if user.birthdate.present?
        csv_row.cell :gender, user.gender_text if user.gender.present?

        map_profile(csv_row, user) if user.profile.present?

        csv_row.cell :sponsor_id, user.sponsor.email if user.sponsor.present?
        @export.progress_tracker.increment_processed_items
      end
    end

    def map_subscriptions(csv_row, user)
      if user.current_subscription.present?
        csv_row.cell :commitment_period_end_at, user.current_subscription.commitment_period
        csv_row.cell :origin_location, I18n.t("location.#{user.current_subscription.origin_location}") if user.current_subscription.origin_location.present?
      else
        map_subscriptions_without_current_subscription(csv_row, user)
      end
    end

    def map_subscriptions_without_current_subscription(csv_row, user)
        return if user.subscriptions.last.nil?
        csv_row.cell :last_subscription_end_at, I18n.l(user.subscriptions.last.try(:decorate).try(:end_at)) if user.subscriptions.last.try(:decorate).try(:end_at).present?
        csv_row.cell :commitment_period_end_at, user.subscriptions.last.try(:decorate).try(:commitment_period)
        csv_row.cell :origin_location, I18n.t("location.#{user.subscriptions.last.origin_location}") if user.subscriptions.last.origin_location.present?
    end

    def map_profile(csv_row, user)
      csv_row.cell :attendance_rate, user.profile.attendance_rate.text if user.profile.attendance_rate.present?
      csv_row.cell :boxing_level, user.profile.boxing_level.text if user.profile.boxing_level.present?

      map_profile_columns(csv_row, user)
    end

    def map_profile_columns(csv_row, user)
      (PROFILE_COLUMNS - [:attendance_rate, :boxing_level]).each do |attribute|
        if user.profile.public_send(attribute).present?
          csv_row.cell attribute, user.profile.public_send(attribute).map(&:text).join(", ")
        end
      end
    end
  end
end
