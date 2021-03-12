namespace :invoices do
  task replace_deferred: :environment do
    Raven.capture do
      Invoice::Deferred::Replace.execute
    end
  end
end
