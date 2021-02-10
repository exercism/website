module Notifications
  class MentorStartedDiscussionNotification < Notification
    # TODO
    def url
      "#"
    end

    def i18n_params
      {
        mentor_name: mentor.handle,
        track_title: track.title,
        exercise_title: exercise.title
      }
    end

    def image_type
      :avatar
    end

    def image_url
      mentor.avatar_url
    end

    def guard_params
      "Discussion##{discussion.id}"
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
