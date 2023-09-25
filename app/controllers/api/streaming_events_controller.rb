class API::StreamingEventsController < API::BaseController
  def index
    render json: AssembleStreamingEvents.(params.permit(*AssembleStreamingEvents.keys))
  end
end
