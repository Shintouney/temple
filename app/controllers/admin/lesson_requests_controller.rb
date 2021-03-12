class Admin::LessonRequestsController < ApplicationController
  include AdminController

  def index
    @lesson_requests = LessonRequest.all

    respond_to do |format|
      format.csv do
        @filename = "Lesson_requests.csv"
        csv_string = CSVExporter::LessonRequests.new(@lesson_requests).execute
        send_csv(csv_string)
      end
    end
  end
end
