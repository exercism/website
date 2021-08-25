module API
  module Mentoring
    module Discussions
      class PreviousSessionsController < BaseController
        def index
          discussion = ::Mentor::Discussion.find_by!(uuid: params[:discussion_uuid])

          discussions = ::Mentor::Discussion::Retrieve.(
            current_user,
            :all,
            student_handle: discussion.student.handle,
            excluded_uuids: [discussion.uuid],
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
  end
end
