module Temp
  class SolutionsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def show
      solution = Solution.find_by!(uuid: params[:id])

      render json: {
        solution: SerializeSolutionForStudent.(solution),
        iterations: solution.iterations.map { |iteration| SerializeIteration.(iteration) },
        latest_iteration: SerializeIteration.(solution.latest_iteration)
      }
    end
  end
end
