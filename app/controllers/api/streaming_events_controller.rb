module API
  class StreamingEventsController < BaseController
    def index
      render json: AssembleStreamingEvents.(params.permit(*AssembleStreamingEvents.keys))
    end
  end
end
