module Slimpay
  class RefreshMandatesJob < ActiveJob::Base
    queue_as :default

    # Refresh mandate for eventual revokations
    def perform
      ::Mandate.ready.each(&:refresh)
    end
  end
end