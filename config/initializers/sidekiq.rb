$redis = Redis.new(url: Settings.redis.url)

Sidekiq.configure_server do |config|
  config.redis = { url: Settings.redis.url }
  config.average_scheduled_poll_interval = 10
  config.failures_max_count = 5000
  config.failures_default_mode = :all
  Settings.sidekiq.each do |k,v|
    config.options[k] = v
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: Settings.redis.url }
  Settings.sidekiq.each do |k,v|
    config.options[k] = v
  end
end

# The Delayed Extensions delay, delay_in and delay_until APIs are no longer available by default. 
# The extensions allow you to marshal job arguments as YAML, leading to cases where job payloads 
# could be many 100s of KB or larger if not careful, leading to Redis networking timeouts or other problems. 
# As noted in the Best Practices wiki page, Sidekiq is designed for jobs with small, simple arguments.
Sidekiq::Extensions.enable_delay!
