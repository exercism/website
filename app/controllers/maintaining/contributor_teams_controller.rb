class Maintaining::ContributorTeamsController < ApplicationController
  before_action :ensure_admin!, except: %i[index show]

  def index
    @teams = ContributorTeam.includes(:memberships).order(type: :asc, github_name: :asc)
    @teams = @teams.for_track(Track.find_by!(slug: params[:track_slug])) if params[:track_slug].present?
    @teams = @teams.page(params[:page]).per(30)
  end

  def show
    @team = ContributorTeam.includes(:memberships).find(params[:id])
    @members_diff = ContributorTeam::DiffMembers.(@team)
  end
end
