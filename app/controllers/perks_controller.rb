class PerksController < ApplicationController
  def index
    @perks = Partner::Perk.all
  end

  def redirect
    perk = Partner::Perk.find_by!(uuid: params[:id])

    Partner::LogPerkClick.defer(perk, current_user, Time.current)

    redirect_to perk.url
  end
end
