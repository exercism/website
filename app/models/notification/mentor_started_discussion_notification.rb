class Notification
  class MentorStartedDiscussionNotification < Notification
    def i18n_params
      {
        mentor_name: mentor.handle,
        track_title: track.title,
        exercise_title: exercise.title
      }
    end

    private
    def track
      exercise.track
    end

    def exercise
      solution.exercise
    end

    def solution
      discussion.solution
    end

    def mentor
      discussion.mentor
    end

    def discussion
      params[:discussion]
    end

    def discussion_post
      params[:discussion_post]
    end
  end
end

