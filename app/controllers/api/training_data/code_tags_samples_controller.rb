class API::TrainingData::CodeTagsSamplesController < API::BaseController
  before_action :use_track, only: :index
  before_action :use_sample, only: :update_tags
  before_action :ensure_trainer!

  def index
    render json: AssembleCodeTagSamples.(params)
  end

  def update_tags
    TrainingData::CodeTagsSample::UpdateTags.(@sample, params[:tags], @sample.next_status, current_user)
    render json: {}
  rescue ::TrainingDataCodeTagsSampleLockedError
    render_400(:training_data_code_tags_sample_locked)
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
  def status = params.fetch(:status, :needs_tagging).to_sym
end
