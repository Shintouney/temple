class Date
  include GlobalID::Identification

  alias_method :id, :to_s
  def self.find(date_string)
    Date.parse(date_string)
  end
end

class Time
  include GlobalID::Identification

  alias_method :id, :to_i
  def self.find(seconds_since_epoch)
    Time.at(seconds_since_epoch.to_i)
  end
end

class ActiveSupport::TimeWithZone
  include GlobalID::Identification

  alias_method :id, :to_i
  def self.find(seconds_since_epoch)
    Time.zone.at(seconds_since_epoch.to_i)
  end
end
