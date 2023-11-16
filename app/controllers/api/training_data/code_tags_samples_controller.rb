class API::TrainingData::CodeTagsSamplesController < API::BaseController
  before_action :use_track, only: :index
  before_action :use_sample, only: :update_tags
  before_action :ensure_trainer!

  def index
    samples = ::TrainingData::CodeTagsSample::Retrieve.(
      params[:status],
      criteria: params[:criteria],
      track: @track,
      page:
    )

    render json: SerializePaginatedCollection.(
      samples,
      serializer: SerializeCodeTagsSamples
    )
  end

  def update_tags
    @sample.update!(tags: params[:tags])

    render json: {}
  end

  private
  def use_track
    return if params[:track_slug].blank?

    @track = Track.for!(params[:track_slug])
  rescue ActiveRecord::RecordNotFound
    render_404(:track_not_found)
  end

  def use_sample
    @sample = TrainingData::CodeTagsSample.find_by!(uuid: params[:id])
    @track = @sample.track
  rescue ActiveRecord::RecordNotFound
    render_404(:sample_not_found)
  end

  def page = [params[:page].to_i, 1].max
end
