module API
  module Mentor
    class InboxController < API::BaseController
      def show
        inbox = ::Mentor::RetrieveInbox.(current_user)
        render json: SerializeMentorInbox.(inbox)
      end
    end
  end
end
