module Mentor
  class Discussion
    class Create
      include Mandate

      initialize_with :mentor, :request, :iteration_idx, :content_markdown

      def call
        discussion = ActiveRecord::Base.transaction do
          request.lock!

          raise StudentCannotMentorThemselvesError if request.student == mentor
          raise SolutionLockedByAnotherMentorError unless request.lockable_by?(mentor)

          # Now we're in the happy path.
          # Mark the request as fulfilled, create the discussion
          # and a first post. If any of these fail then the
          # whole load need to fail.
          request.fulfilled!

          Mentor::Discussion.create!(
            mentor: mentor,
            request: request,
            awaiting_student_since: Time.current
          ).tap { |d| process_discussion!(d) }
        end

        # This must be outside of the transaction above as it
        # changes the transaction isolation level
        Mentor::StudentRelationship::CacheNumDiscussions.(mentor, student)

        discussion
      end

      def process_discussion!(discussion)
        discussion_post = Mentor::DiscussionPost.create!(
          iteration: iteration,
          discussion: discussion,
          author: mentor,
          content_markdown: content_markdown
        )

        User::Notification::Create.(
          student,
          :mentor_started_discussion,
          {
            discussion: discussion,
            discussion_post: discussion_post
          }
        )
      end

      memoize
      def iteration
        request.solution.iterations.find_by!(idx: iteration_idx)
      end

      memoize
      def student
        request.solution.user
      end
    end
  end
end
