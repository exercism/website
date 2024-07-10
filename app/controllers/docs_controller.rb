class DocsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :ensure_onboarded!
  before_action :use_track, only: %i[track_index track_show]
  before_action :use_section, only: %i[section show]

  def index; end

  def section
    @doc = Document.find_by!(section: @section, slug: "APEX")
    render action: :show
  end

  def show
    @doc = @nav_docs.find(params[:slug])
    render action: :show
  end

  def tracks; end

  def track_index; end

  def track_show
    @doc = @nav_docs.find(params[:slug])
    @section = :tracks
    render action: :show
  end

  private
  def use_section
    @section = params[:section].to_sym
    @nav_docs = Document.where(section: @section)
  end

  def use_track
    @track = Track.find(params[:track_slug])
    @nav_docs = Document.where(track_id: @track.id)

    render_404 unless @track.accessible_by?(current_user)
  end
end
