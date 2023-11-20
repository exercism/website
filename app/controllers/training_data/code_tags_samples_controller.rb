class TrainingData::CodeTagsSamplesController < ApplicationController
  before_action :use_track, only: [:next]
  before_action :use_sample, only: [:show]
  before_action :ensure_trainer!

  def index; end

  def show; end

  def next
    sample = TrainingData::CodeTagsSample::RetrieveNext.(@track, params[:status])
    return redirect_to training_data_root_path if sample.nil?

    sample.lock_for_editing!(current_user)

    redirect_to training_data_code_tags_sample_path(sample, status: params[:status])
  end

  private
  def use_track
    @track = Track.for!(params[:track])
  rescue ActiveRecord::RecordNotFound
    render_404(:track_not_found)
  end

  def use_sample
    @sample = TrainingData::CodeTagsSample.find_by!(uuid: params[:id])
    @track = @sample.track
  rescue ActiveRecord::RecordNotFound
    render_404(:sample_not_found)
  end

  def ensure_trainer!
    return if current_user.trainer?(@track)

    render_403(:not_trainer)
  end
end
