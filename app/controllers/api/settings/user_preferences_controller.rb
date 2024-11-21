class API::Settings::UserPreferencesController < API::BaseController
  def update
    render json: {}, status: :ok if current_user.preferences.update(user_preferences_params)
  end

  def enable_solution_comments
    current_user.solutions.update_all(allow_comments: true)
    respond_to_enabling_comments!
  end

  def disable_solution_comments
    current_user.solutions.update_all(allow_comments: false)
    respond_to_enabling_comments!
  end

  def bootcamp_affiliate_coupon_code
    code = User::GenerateBootcampAffiliateCouponCode.(current_user)

    if code
      render json: { coupon_code: code }
    else
      render_403(:could_not_generate_coupon_code)
    end
  end

  def bootcamp_free_coupon_code
    code = User::GenerateBootcampFreeCouponCode.(current_user)

    if code
      render json: { coupon_code: code }
    else
      render_403(:could_not_generate_coupon_code)
    end
  end

  private
  def user_preferences_params
    params.
      require(:user_preferences).
      permit(*User::Preferences.keys).tap do |ps|
      # TODO: Add a test for this
      ps[:theme] = "light" if ps[:theme] == "dark" && !current_user.insider?
      ps[:hide_website_adverts] = false unless current_user.insider?
    end
  end

  def respond_to_enabling_comments!
    render json: {
      num_published_solutions: current_user.solutions.published.count,
      num_solutions_with_comments_enabled: current_user.solutions.published.where(allow_comments: true).count
    }
  end
end
