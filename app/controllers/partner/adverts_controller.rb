class Partner::AdvertsController < ApplicationController
  def redirect
    advert = Partner::Advert.find_by!(uuid: params[:id])

    Partner::LogAdvertClick.defer(
      advert, current_user, Time.current, params[:impression_uuid]
    )

    redirect_to advert.url
  end
end
