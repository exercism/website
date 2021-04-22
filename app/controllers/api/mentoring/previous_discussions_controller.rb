module API
  class Mentoring::PreviousDiscussionsController < BaseController
    def index
      discussions = ::Mentor::Discussion::Retrieve.(
        current_user,
        :finished,
        page: params[:page]
      )

      render json: SerializePaginatedCollection.(
        discussions,
        serializer: SerializeMentorDiscussions,
        serializer_args: :mentor
      )
    end
  end
end
