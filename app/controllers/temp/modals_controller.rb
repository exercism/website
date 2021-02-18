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

    def reputation
      if current_user.reputation_tokens.size < 2
        User::ReputationToken::Create.(
          current_user,
          :code_review,
          external_link: "https://github.com/exercism/ruby/pulls/120",
          repo: "ruby/pulls",
          pr_id: 120
        )
        User::ReputationToken::Create.(
          current_user,
          :code_review,
          external_link: "https://github.com/exercism/ruby/pulls/125",
          repo: "ruby/pulls",
          pr_id: 125
        )
      end

      @tokens = User::ReputationToken::Search.(current_user).map(&:rendering_data)
    end
  end
end
