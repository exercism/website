class ProfilesController < ApplicationController
  skip_before_action :authenticate_user!, except: %i[intro new create]
  before_action :use_user, except: %i[index intro new create]
  before_action :use_profile, except: %i[index intro new create tooltip]

  def index
    redirect_to contributing_contributors_path
  end

  def show
    # TODO: (Required) Order all these by most prominent first
    @solutions = @user.solutions.published.first(3)
    @testimonials = @user.mentor_testimonials.published.first(3)

    @num_total_solutions = @user.solutions.published.count
    @num_testimonials = @user.mentor_testimonials.published.count
  end

  def solutions
    @solutions = Solution::SearchUserSolutions.(
      @user,
      status: :published
    )
  end

  def contributions; end

  # TODO: (Optional) Add tests for published scope
  def testimonials
    @num_solutions_mentored = @user.mentor_discussions.count
    @num_students_helped = @user.mentor_discussions.joins(:solution).distinct.count(:user_id)
    @num_testimonials = @user.mentor_testimonials.published.count

    @testimonials = @user.mentor_testimonials.published.sort_by { rand }
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

  def create
    return render :new, status: :unprocessable_entity if params[:user].blank?

    if current_user.update(params[:user].permit(:name, :location, :bio))
      begin
        current_user.create_profile!
      rescue ActiveRecord::RecordNotUnique
        # Handle a double-click gracefully
      end

      redirect_to profile_path(current_user, first_time: true)
    else
      render :new, status: :unprocessable_entity
    end
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
