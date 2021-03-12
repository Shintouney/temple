module I18n
  def self.raise_exception(*args)
    raise "i18n #{args.first}"
  end
end
