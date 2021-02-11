# TODO: Remove
module Temp
  class ModalsController < ApplicationController
    def completed_exercise
      @solution = current_user.solutions.first
      @exercise = @solution.exercise
      @track = @exercise.track
      @user_track = UserTrack.for(current_user, @track)

      if @exercise.concept_exercise?
        @concepts = @exercise.taught_concepts
        @unlocked_concepts = [] # TODO
        @unlocked_exercises = [] # TODO
      else
        @concepts = @exercise.prerequisites
      end

      @unlocked_exercises = @track.exercises.limit(2)
      @unlocked_concepts = @track.concepts.limit(2)
    end

    def mentoring_sessions
      @num_total_discussions = 87
      @student = User.second
      @discussion = Solution::MentorDiscussion.first
    end

    def notifications
      @notifications = SerializeUserNotifications.(
        [
          User::Notifications::AcquiredBadgeNotification.create!(
            user: User.first,
            version: 1,
            params: { badge: Badge.first }
          ),
          User::Notifications::MentorStartedDiscussionNotification.create!(
            user: User.first,
            version: 1,
            params: {
              mentor: User.second,
              track: Track.first,
              exercise: Exercise.first,
              discussion: Solution::MentorDiscussion.create!(mentor: User.first,
                                                             solution: Solution.first)
            },
            read_at: Time.current
          )
        ]
      )
    end
  end
end
