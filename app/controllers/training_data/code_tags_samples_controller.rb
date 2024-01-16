class TrainingData::CodeTagsSamplesController < ApplicationController
  before_action :use_track, only: [:next]
  before_action :use_sample, only: [:show]
  before_action :ensure_trainer!

  def index
    @training_data_dashboard_params = params.permit(:status, :order, :criteria, :page, :track_slug)
    @statuses = %w[needs_tagging needs_checking needs_checking_admin]
  end

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

    redirect_to training_data_code_tags_samples_path(status: params[:status])
  end

  private
  def use_track
    @track = Track.for!(params[:track])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def use_sample
    @sample = TrainingData::CodeTagsSample.find_by!(uuid: params[:id])
    @track = @sample.track
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
