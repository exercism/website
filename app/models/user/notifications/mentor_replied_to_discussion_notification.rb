class User
  module Notifications
    class MentorRepliedToDiscussionNotification < Notification
      params :discussion_post

      before_validation on: :create do
        self.track = solution.track
        self.exercise = solution.exercise
      end

      def url = discussion.student_url

      def i18n_params
        {
          mentor_name: mentor.handle,
          track_title: track.title,
          exercise_title: exercise.title
        }
      end

      def image_type = :avatar

      def image_url
        mentor.avatar_url
      end

      def guard_params = "DiscussionPost##{discussion_post.id}"

      delegate :discussion, to: :discussion_post

      private
      def solution
        discussion_post.solution
      end

      def mentor
        discussion_post.author
      end
    end
  end
end
