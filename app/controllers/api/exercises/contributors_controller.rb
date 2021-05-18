module API
  module Exercises
    class ContributorsController < BaseController
      def index
        exercise = Exercise.find(params[:exercise_id])

        render json: {
          contributors: exercise.authors.map do |author|
            { handle: author.handle }
          end
        }
      end
    end
  end
end
