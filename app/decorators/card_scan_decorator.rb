class CardScanDecorator < ApplicationDecorator
  delegate_all

  decorates_association :user

  # Public: The scanned_at value in a short
  # localized format.
  #
  # Returns a String.
  def scanned_at_human_time
    format = object.scanned_at.today? ? '%H:%M' : '%d/%m %H:%M'

    I18n.l card_scan.scanned_at, format: format
  end

  # Public: Renders the record as a Hash usable for JSON output.
  #
  # Returns a Hash.
  def to_api_json
    object.
      as_json(only: [:accepted, :card_reference, :scanned_at]).
      merge(scan_point: scan_point_value).
      stringify_keys
  end

  # Public: Renders the record errors as a Hash usable for JSON output.
  #
  # Returns a Hash.
  def error_messages_as_json
    { errors: object.errors.messages }
  end
end
