class Partner::AdvertsController < ApplicationController
  skip_before_action :authenticate_user!

  def redirect
    advert = Partner::Advert.find_by!(uuid: params[:id])

    unless request.is_crawler?
      Partner::LogAdvertClick.defer(
        advert, current_user, Time.current, params[:impression_uuid]
      )
    end

    redirect_to advert.url, allow_other_host: true
  end
end
