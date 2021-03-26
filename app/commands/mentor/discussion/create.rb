module Mentor
  class Discussion
    class Create
      include Mandate

      initialize_with :mentor, :request, :iteration_idx, :content_markdown

      # TODO: Guard against a user mentoring their own solution and
      # catch whatever exception is raised in the controller and handle
      # gracefully.
      def call
        ActiveRecord::Base.transaction do
          request.lock!

          raise SolutionLockedByAnotherMentorError unless request.lockable_by?(mentor)

          # Now we're in the happy path.
          # Mark the request as fulfilled, create the discussion
          # and a first post. If any of these fail then the
          # whole load need to fail.
          request.fulfilled!

          discussion = Mentor::Discussion.create!(
            mentor: mentor,
            request: request
          )

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

          Mentor::StudentRelationship::CacheNumDiscussions.(mentor, student)

          discussion
        end
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
