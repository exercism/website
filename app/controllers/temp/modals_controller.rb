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
      if current_user.notifications.unread.size < 2
        User::Notifications::AcquiredBadgeNotification.create!(
          user: User.first,
          version: 1,
          params: { badge: Badge.first }
        )
        User::Notifications::MentorStartedDiscussionNotification.create!(
          user: User.first,
          version: 1,
          params: {
            mentor: User.second,
            track: Track.first,
            exercise: Exercise.first,
            discussion: Solution::MentorDiscussion.create!(
              mentor: User.first,
              solution: Solution.first
            )
          },
          read_at: Time.current
        )
      end

      @notifications = SerializeUserNotifications.(current_user.notifications.unread.limit(5))
      @unrevealed_badges = SerializeUserAcquiredBadges.(current_user.unrevealed_badges)
    end

    def reputation
      if current_user.reputation_tokens.size < 2
        User::ReputationToken.create!(
          user: current_user,
          context_key: "reviewed_code/ruby/pulls/100",
          external_link: "https://github.com",
          reason: :reviewed_code,
          category: :building
        )
        User::ReputationToken.create!(
          user: current_user,
          context_key: "reviewed_code/ruby/pulls/120",
          external_link: "https://github.com",
          reason: :reviewed_code,
          category: :building
        )
      end

      @tokens = SerializeReputationTokens.(User::ReputationToken::Search.(current_user))
    end
  end
end
