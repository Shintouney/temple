module Lessons
  class CreateJob < ActiveJob::Base
    queue_as :default

    def perform
      ::Raven.capture do
        ::Lessons::CreateFromLessonTemplates.new.execute
      end
    end
  end
end