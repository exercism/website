class API::Tracks::TagsController < API::BaseController
  before_action :ensure_maintainer!
  before_action :use_track
  before_action :use_tag

  def filterable
    @tag.update!(filterable: true)
    render json: {}
  end

  def not_filterable
    @tag.update!(filterable: false)
    render json: {}
  end

  def enabled
    @tag.update!(enabled: true)
    render json: {}
  end

  def not_enabled
    @tag.update!(enabled: false)
    render json: {}
  end

  private
  def use_track
    @track = Track.find(params[:track_slug])
  rescue StandardError
    render_404(:track_not_found)
  end

  def use_tag
    @tag = @track.analyzer_tags.find_by!(tag: params[:tag])
  end
end
