class TrainingData::CodeTagsSamplesController < ApplicationController
  before_action :use_track, only: [:next]
  before_action :use_sample, only: [:show]
  before_action :ensure_trainer!

  def index; end

  def show; end

  def next
    3.times do
      sample = TrainingData::CodeTagsSample::RetrieveNext.(@track, params[:status])
      next if sample.nil?

      begin
        sample.lock_for_editing!(current_user)
      rescue ::TrainingDataCodeTagsSampleLockedError
        # We'll retry when we could not lock the sample
        next
      end

      return redirect_to training_data_code_tags_sample_path(sample, status: params[:status])
    end

    redirect_to training_data_root_path
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
