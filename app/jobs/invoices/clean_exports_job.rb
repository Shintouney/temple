class Invoices::CleanExportsJob < ActiveJob::Base
  queue_as :default

  # Remove Export CSV files older than a month. Keep only 1 of each invoice subtype.
  def perform
    @entries = Dir.entries(::Export::PATH).delete_if{|file_name| ['.', '..'].include?(file_name)}
    @subtypes = ['unfinished', 'finished', 'special']
    @unfinished = []
    @finished = []
    @specials = []

    fill_arrays
    sort_arrays
    pop_the_one_to_keep

    # Delete remaining listed files
    [@unfinished, @finished, @specials].flatten.each do |file_name|
      ::File.delete("#{ ::Export::PATH }/#{ file_name }")
    end
  end

  private

  def fill_arrays
    # List each file older than a month.
    @entries.each do |file_name|
      change_date = ::File.new("#{ ::Export::PATH }/#{ file_name }").mtime
      recent_file = change_date > ::Time.now.advance(months: -1)
      next if recent_file
      is_unfinish = file_name.match(/.*\s(#{ @subtypes[0] })\s.*/).present?
      is_finish = file_name.match(/.*\s(#{ @subtypes[1] })\s.*/).present?
      is_special = file_name.match(/.*\s(#{ @subtypes[2] })\s.*/).present?

      @unfinished << file_name if is_unfinish
      @finished << file_name if is_finish
      @specials << file_name if is_special
    end
  end

  def sort_arrays
    # Sort arrays to keep most recent at the end of each.
    @unfinished = @unfinished.sort
    @finished = @finished.sort
    @specials = @specials.sort
  end

  def pop_the_one_to_keep
    # Keep last element - most recent
    @unfinished.pop
    @finished.pop
    @specials.pop
  end
end
