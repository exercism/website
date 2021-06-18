class Maintaining::ContributorTeamsController < ApplicationController
  def index
    @teams = ContributorTeam.includes(:memberships).order(type: :asc, name: :asc)
    @teams = @teams.for_track(Track.find_by!(slug: params[:track_slug])) if params[:track_slug].present?
    @teams = @teams.page(params[:page]).per(30)
  end

  def show
    @team = ContributorTeam.includes(:memberships).find(params[:id])
  end

  def new
    @team = ContributorTeam.new
    @type_options = %i[track_maintainers project_maintainers reviewers].map do |type|
      [type.to_s.humanize, type]
    end
    @track_options = Track.order(title: :asc).pluck(:title, :slug)
  end

  def create
    @team = ContributorTeam.new(team_params)

    if @team.save
      redirect_to maintaining_contributor_team_path(@team)
    else
      render :new
    end
  end

  private
  def team_params
    sanitized_params = params.require(:contributor_team).permit(:name, :github_name, :type, :track)
    sanitized_params[:track] = sanitized_params[:track].blank? ? nil : Track.find_by(slug: sanitized_params[:track])
    sanitized_params
  end
end
