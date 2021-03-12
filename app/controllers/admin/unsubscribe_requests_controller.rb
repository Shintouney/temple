class Admin::UnsubscribeRequestsController < ApplicationController
  include AdminController

  def index
    @unsubscribe_requests = UnsubscribeRequest.all

    respond_to do |format|
      format.csv do
        @filename = "Unsubscribe_requests.csv"
        csv_string = CSVExporter::UnsubscribeRequests.new(@unsubscribe_requests).execute
        send_csv(csv_string)
      end
    end
  end
end
