module Visits
  class SweepJob < ActiveJob::Base
    queue_as :default

    def perform(*args)
      ::Raven.capture do
        ::Visit::Sweeper.new.execute
      end
    end
  end
end