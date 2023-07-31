class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
    end
  end

  def unacceptable
    respond_to do |format|
      format.html { render_html(422) }
      format.json { render json: { error: "Params unacceptable" }, status: :unprocessable_entity }
    end
  end

  def internal_error
    respond_to do |format|
      format.html { render_html(500) }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end

  private
  def render_html(status)
    @status_code = status
    render "error", status:
  end
end
