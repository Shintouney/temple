RSpec.configure do |config|
  config.before(:suite) do
    RedisTest.start(log_to_stdout: false)
    # if log_to_stdout ommited it will logs to file
    RedisTest.configure(:default, :sidekiq)
    # RedisTest provide common configuration for :default (set
    # Redis.current + ENV['REDIS_URL']), :sidekiq, :ohm (set Ohm.redis) and :resque.
  end

  config.after(:each) do
    RedisTest.clear
    # notice that will flush the Redis db, so it's less
    # desirable to put that in a config.before(:each) since it may clean any
    # data that you try to put in redis prior to that
  end

  config.after(:suite) do
    RedisTest.stop
  end
end
