class Admin::SponsoringRequestsController < ApplicationController
  include AdminController

  def index
    @sponsoring_requests = SponsoringRequest.all

    respond_to do |format|
      format.csv do
        @filename = "Sponsoring_requests.csv"
        csv_string = CSVExporter::SponsoringRequests.new(@sponsoring_requests).execute
        send_csv(csv_string)
      end
    end
  end
end
