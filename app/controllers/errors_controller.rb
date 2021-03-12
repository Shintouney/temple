class ErrorsController < ActionController::Base
  def not_found
    respond_to do |format|
      format.html { render layout: "errors", status: :not_found }
      format.all { render nothing: true, status: :not_found }
    end
  end

  def unacceptable_entity
    respond_to do |format|
      format.html { render layout: "errors", status: :unprocessable_entity }
      format.all { render nothing: true, status: :unprocessable_entity }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render layout: "errors", status: :internal_server_error }
      format.all { render nothing: true, status: :internal_server_error }
    end
  end
end
