module API
  module Mentor
    class QueueController < API::BaseController
      def show
        queue = ::Mentor::RetrieveQueue.(current_user)
        render json: SerializeMentorQueue.(queue)
      end
    end
  end
end
