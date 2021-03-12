# Invoices::ReplaceDeferredJob.perform_later HOTFIX
record_invalid_ids = []
argument_error_ids = []
Invoice.with_state(:open).includes(:user).due.each do |invoice| 
  puts "invoice #{invoice.id}"
  begin
    Invoice::Deferred::Close.new(invoice).execute
  rescue ActiveRecord::RecordInvalid => e
    puts e.to_s
    record_invalid_ids << invoice.id
  rescue ArgumentError => e
    puts e.to_s
    argument_error_ids << invoice.id
  end
end

# Invoice IDS ArgumentError:
# => [88237]

# Invoice IDS discount_period < 0
# => [87816, 88096, 88404, 88966]

# Invoices::ChargesPendingDeferredJob.perform_later HOTFIX
record_invalid_ids = []
argument_error_ids = []
other_error_ids = []
::Invoice.pending.due.each do |invoice|
  puts "invoice #{invoice.id}"
  begin
    ::Invoice::Deferred::Charge.new(invoice).execute
  rescue ActiveRecord::RecordInvalid => e
    puts e.to_s
    record_invalid_ids << invoice.id
  rescue ArgumentError => e
    puts e.to_s
    argument_error_ids << invoice.id
  rescue => e
    puts e.to_s
    other_error_ids << invoice.id
  end
end

# Invoice IDS ArgumentError:
# => [65822, 67883]