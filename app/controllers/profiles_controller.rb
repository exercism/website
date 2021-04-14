class ProfilesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :use_profile

  def show
    raise ActiveRecord::RecordNotFound unless @profile

    # TODO: Order all these by most prominent first
    @solutions = @user.solutions.published.first(3)
    @testimonials = @user.mentor_testimonials.published.first(3)

    @num_total_solutions = @user.solutions.published.count
    @num_testimonials = @user.mentor_testimonials.count
  end

  def solutions
    @solutions = Solution::SearchUserSolutions.(
      @user,
      status: :published
    )
  end

  def contributions
    @building_tokens = @user.reputation_tokens.where(category: %i[building authoring]).page(1).per(20)
    @maintaining_tokens = @user.reputation_tokens.where(category: :maintaining).page(1).per(20)
    @authored_exercises =
      Exercise.where(id: @user.authored_exercises.select(:id) + @user.contributed_exercises.select(:id)).
        order(id: :desc).
        page(1).per(20).
        includes(:track)

    # Kntsoriano: This is what you want to use to get the tab counts
    @counts = @user.reputation_tokens.group(:category).count
  end

  def badges
    @badges = @user.badges
  end

  def tooltip
    expires_in 1.minute

    render_template_as_json
  end

  private
  def use_profile
    @user = User.find_by(handle: params[:id])
    @profile = @user.profile
  end
end
