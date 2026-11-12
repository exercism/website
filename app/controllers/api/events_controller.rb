module API
  class EventsController < BaseController
    before_action :authenticate_user!

    def create
      tracked = Analytics::TrackBrowserEvent.(current_user, params[:event].to_s, properties: event_properties)

      head(tracked ? :no_content : :unprocessable_entity)
    end

    private
    def event_properties
      return {} unless params[:properties].respond_to?(:permit)

      params[:properties].permit(:trigger, :payment_type, :amount_in_cents, :error_code, :decline_code).to_h
    end
  end
end
