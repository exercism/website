class LegacyController < ApplicationController
  skip_before_action :authenticate_user!

  def solution
    solution = Solution.find_by!(uuid: params[:uuid])
    if user_signed_in? && solution.user_id == current_user.id
      redirect_to Exercism::Routes.private_solution_url(solution)
    elsif solution.published?
      redirect_to Exercism::Routes.published_solution_url(solution)
    else
      raise ActiveRecord::RecordNotFound # Simulate a 404
    end
  end
end
