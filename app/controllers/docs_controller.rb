class DocsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :use_track, only: %i[track_index track_show]

  def index; end

  def show
    Document.find(params[:slug])
  end

  def track_index; end

  def track_show
    @doc = Document.where(track: @track).find(params[:slug])
  end

  private
  def use_track
    @track = Track.find(params[:track_slug])
    @nav_docs = Document.where(track_id: @track.id)
  end
end
