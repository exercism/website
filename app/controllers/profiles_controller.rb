class ProfilesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :use_user, except: %i[intro new create]
  before_action :use_profile, except: %i[intro new create tooltip]

  def show
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

  def contributions; end

  def testimonials
    # TODO: Added lots for now to show them off. Remove this.
    @testimonials = @user.mentor_testimonials.sort_by { rand } * 5
  end

  def badges
    @badges = @user.badges
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
    if params[:user]
      current_user.update!(
        params[:user].
        permit(:name, :location, :bio, :pronouns)
      )
    end

    begin
      current_user.create_profile!
    rescue ActiveRecord::RecordNotUnique
      # Handle a double-click gracefully
    end
    redirect_to profile_path(current_user, first_time: true)
  end

  private
  def use_user
    @user = User.find_by(handle: params[:id])
  end

  def use_profile
    @profile = @user&.profile

    unless @profile # rubocop:disable Style/GuardClause
      return redirect_to action: :intro if current_user&.handle == params[:id]

      raise ActiveRecord::RecordNotFound
    end
  end
end
