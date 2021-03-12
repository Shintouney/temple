class Invoices::ReplaceDeferredJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    ::Raven.capture do
      ::Invoice::Deferred::Replace.execute
    end
  end
end
