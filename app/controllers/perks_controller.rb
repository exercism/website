class PerksController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @perks = Partner::Perk.active.includes(
      partner: {
        light_logo_attachment: :blob,
        dark_logo_attachment: :blob
      },
      light_logo_attachment: :blob,
      dark_logo_attachment: :blob
    )
  end

  def show
    @perk = Partner::Perk.find_by!(uuid: params[:id])
    @partner = @perk.partner
  end

  def claim
    perk = Partner::Perk.find_by!(uuid: params[:id])

    Partner::LogPerkClick.defer(perk, current_user, Time.current) unless request.is_crawler?

    url = params[:partner_url] ? perk.partner.website_url : perk.url_for_user(current_user)
    redirect_to url, allow_other_host: true
  end
end
