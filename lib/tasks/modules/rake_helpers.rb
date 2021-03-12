module RakeHelpers
  def display_results(unmatched_entries)
    if unmatched_entries.size == 0
      $stdout.puts "\e[32m0\e[0m error."
    else
      $stdout.puts "\e[31m#{unmatched_entries.size} errors\e[0m."
    end
  end
end
