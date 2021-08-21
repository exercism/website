class LegacyController < ApplicationController
  skip_before_action :authenticate_user!, only: [:solution]

  def solution
    solution = Solution.find_by!(uuid: params[:uuid])
    return render_404 unless solution.published?

    redirect_to Exercism::Routes.published_solution_url(solution)
  end

  def my_solution
    solution = Solution.find_by!(uuid: params[:uuid])
    return render_404 unless solution.user_id == current_user.id

    redirect_to Exercism::Routes.private_solution_url(solution)
  end

  def mentor_solution
    solution = Solution.find_by!(uuid: params[:uuid])
    discussion = solution.mentor_discussions.where(mentor: current_user).first
    return render_404 unless discussion

    redirect_to mentoring_discussion_url(discussion)
  end
end
