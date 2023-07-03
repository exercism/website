class PerksController < ApplicationController
  def index
    @perks = Partner::Perk.all
  end

  def show
    @perk = Partner::Perk.find_by!(uuid: params[:id])
    @partner = @perk.partner
  end

  def claim
    perk = Partner::Perk.find_by!(uuid: params[:id])

    Partner::LogPerkClick.defer(perk, current_user, Time.current)

    redirect_to perk.url_for_user(current_user), allow_other_host: true
  end
end