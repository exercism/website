# TODO: (Optional) Remove
module Temp
  class ModalsController < ApplicationController
    def completed_exercise
      @solution = current_user.solutions.first
      @exercise = @solution.exercise
      @track = @exercise.track
      @user_track = UserTrack.for(current_user, @track)

      if @exercise.concept_exercise?
        @concepts = @exercise.taught_concepts
        @unlocked_concepts = [] # TODO: (Optional)
        @unlocked_exercises = [] # TODO: (Optional)
      else
        @concepts = @exercise.prerequisites
      end

      @unlocked_exercises = @track.exercises.limit(2)
      @unlocked_concepts = @track.concepts.limit(2)
    end

    def mentoring_sessions
      @num_total_discussions = 87
      @student = User.second
      @discussion = Mentor::Discussion.first
    end

    def reputation
      if current_user.reputation_tokens.size < 2
        User::ReputationToken::Create.(
          current_user,
          :code_review,
          external_url: "https://github.com/exercism/ruby/pulls/120",
          repo: "ruby/pulls",
          node_id: 120
        )
        User::ReputationToken::Create.(
          current_user,
          :code_review,
          external_url: "https://github.com/exercism/ruby/pulls/125",
          repo: "ruby/pulls",
          node_id: 125
        )
      end

      @tokens = User::ReputationToken::Search.(current_user).map(&:rendering_data)
    end

    def mentoring_dropdown
      @active_mentoring_discussion = false
      @discussions = Mentor::Discussion.limit(2)
    end

    def exercise_tooltip
      @solution = current_user.solutions.first
      @exercise = @solution.exercise
    end

    def select_exercise_for_mentoring
      @solutions = Solution.limit(5)
    end
  end
end
