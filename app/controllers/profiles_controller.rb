class ProfilesController < ApplicationController
  skip_before_action :authenticate_user!, except: %i[intro new create]
  before_action :use_user, except: %i[index intro new create]
  before_action :use_profile, except: %i[index intro new create tooltip]

  def index
    redirect_to contributing_contributors_path
  end

  def show
    @solutions = @user.solutions.published.order(num_stars: :desc, updated_at: :desc).first(3)

    # TODO: (Required) Order by most prominent first (what is the most prominent testimonial?)
    @testimonials = @user.mentor_testimonials.published.first(3)

    @num_total_solutions = @user.solutions.published.count
    @num_testimonials = @user.mentor_testimonials.published.count
  end

  def solutions
    redirect_to profile_path(@user) unless @profile.solutions_tab?

    @solutions = Solution::SearchUserSolutions.(
      @user,
      status: :published
    )
  end

  def contributions
    redirect_to profile_path(@user) unless @profile.contributions_tab?
  end

  # TODO: (Optional) Add tests for published scope
  def testimonials
    redirect_to profile_path(@user) unless @profile.testimonials_tab?

    @num_solutions_mentored = @user.mentor_discussions.count
    @num_students_helped = @user.mentor_discussions.joins(:solution).distinct.count(:user_id)
    @num_testimonials = @user.mentor_testimonials.published.count
  end

  def badges
    @badges = Badge.where(id: @user.acquired_badges.revealed.select(:badge_id))
    @rarities = @badges.group(:rarity).count
  end

  def tooltip
    expires_in 1.minute

    render_template_as_json
  end

  def intro
    return redirect_to profile_path(current_user) if current_user&.profile
  end

  def new
    return redirect_to profile_path(current_user) if current_user&.profile

    @profile = User::Profile.new
  end

  private
  def use_user
    @user = User.find_by(handle: params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def use_profile
    @profile = @user&.profile

    unless @profile # rubocop:disable Style/GuardClause
      return redirect_to action: :intro if current_user&.handle == params[:id]

      render_404
    end
  end
end
