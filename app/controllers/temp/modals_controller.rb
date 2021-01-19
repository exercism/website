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
  end
end
