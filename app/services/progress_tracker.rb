# encoding: UTF-8
class ProgressTracker
  attr_reader :redis_key

  # Public: Initialize a ProgressTracker.
  #
  # options - The Hash of options (default: {}):
  #           :subtype - The String subtype to prefix key.
  #           :export_type       - The String Redis key.
  #
  # Returns a new instance of ProgressTracker.
  def initialize(options={})
    subtype = options.fetch(:subtype, nil)
    @redis_key = subtype ? "#{subtype}:#{options[:export_type]}" : options[:export_type]
  end

  # Public: Create Redis hset filled with default processed_items and total_items.
  #
  # total_items - The Integer total items to track.
  #
  # Returns nothing.
  def create(total_items)
    $redis.hmset(redis_key, :processed_items, 0, :total_items, total_items)
  end

  # Public: Increment the number of processed items by 1.
  #
  # Returns nothing.
  def increment_processed_items
    processed_items = $redis.hgetall(redis_key)['processed_items'].to_i
    processed_items += 1

    $redis.hset(redis_key, :processed_items, processed_items)
  end

  def delete
    $redis.del(redis_key)
  end

  # Public: Calculate progress percentage based on processed items and
  # total items.
  #
  # Returns the Integer percentage.
  def progress_percentage
    progress = $redis.hgetall(redis_key)

    if progress.present?
      return 100 if progress['total_items'] == '0'
      (progress['processed_items'].to_f / progress['total_items'].to_f) * 100
    else
      100
    end
  end

  # Public: Check either the current progress tracker is in progress.
  #
  # Returns the Boolean in_process.
  def in_progress?
    $redis.keys(redis_key).present?
  end
end
