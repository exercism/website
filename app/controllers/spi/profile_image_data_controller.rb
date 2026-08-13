module SPI
  # Feeds the profile share image generator over the internal ALB, avoiding the
  # Cloudflare IP-allowlisting the public site would need.
  class ProfileImageDataController < BaseController
    def show
      user = User.find_by!(handle: params[:user_handle])

      # Mirrors ImagesController's 404, so the generator fails loudly rather
      # than caching a blank image against this URL.
      raise ActiveRecord::RecordNotFound unless user.profile

      render json: SerializeProfileImage.(user)
    end
  end
end
