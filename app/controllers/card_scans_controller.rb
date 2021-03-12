class CardScansController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :verify_x_authenticity_token, :load_user

  def create
    respond_to do |format|
      format.json do
        @create_user_card_scan = CardScan::Create.new(@user, card_scan_param)

        if @create_user_card_scan.execute
          render json: @create_user_card_scan.card_scan.decorate.to_api_json, status: 201
        else
          render json: @create_user_card_scan.card_scan.decorate.error_messages_as_json, status: 400
        end
      end
    end
  end

  private

  def verify_x_authenticity_token
    render nothing: true, status: 401 unless request.headers["X-Auth"] == Settings.api.token
  end

  def load_user
    @user = User.where(card_reference: card_scan_param[:card_reference]).first
    render nothing: true, status: 404 if @user.nil?
  end

  def card_scan_param
    parsed_json_body.permit(:accepted, :scanned_at, :scan_point, :card_reference)
  end

  def parsed_json_body
    @parsed_json_body ||= ActionController::Parameters.new(JSON.parse(request.body.read))
  end
end
