class Notification
  class MentorRepliedToDiscussionNotification < Notification
    def i18n_params
      {
        mentor_name: mentor.handle,
        track_title: track.title,
        exercise_title: exercise.title
      }
    end

    def guard_params
      "DiscussionPost##{discussion_post.id}"
    end

    private
    def track
      exercise.track
    end

    def exercise
      solution.exercise
    end

    def solution
      discussion_post.solution
    end

    def mentor
      discussion_post.user
    end

    def discussion_post
      params[:discussion_post]
    end
  end
end
