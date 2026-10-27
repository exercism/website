class API::UsersController < API::BaseController
  def show
    render json: {
      user: {
        handle: current_user.handle,
        insiders_status: current_user.insiders_status
      }
    }
  end

  def update
    if params.dig(:user, :avatar).present?
      begin
        User::UpdateAvatar.(current_user, params.require(:user)[:avatar])
      rescue ActiveRecord::RecordInvalid => e
        raise unless e.record.errors.include?(:avatar)

        return render_400(:invalid_avatar_format, errors: e.record.errors)
      end
    end

    if params.dig(:user, :seniority).present?
      current_user.update(
        seniority: params.require(:user)[:seniority]
      )
    end

    render json: {
      user: {
        handle: current_user.handle,
        avatar_url: current_user.avatar_url,
        has_avatar: current_user.has_avatar?
      }
    }
  end

  def activate_insiders
    User::InsidersStatus::Activate.(current_user)

    render json: {
      links: {
        redirect_url: insiders_url
      }
    }
  end
end
