class TrainingData::CodeTagsSamplesController < ApplicationController
  before_action :use_track, only: [:next]
  before_action :use_sample, only: [:show]
  before_action :ensure_trainer!

  def index; end

  def show; end

  def next
    sample = TrainingData::CodeTagsSample::RetrieveNext.(@track, params[:status])
    redirect_to action: :index if sample.nil?

    sample.lock_for_editing!(current_user)

    redirect_to action: :show, uuid: sample.uuid, status: params[:status]
  end

  private
  def use_track
    @track = Track.find(params[:track_id])
  rescue StandardError
    redirect_to(action: :index)
  end

  def use_sample
    @sample = TrainingData::CodeTagsSample.find_by(uuid: params[:id])
    @track = @sample.track
  rescue StandardError
    redirect_to(action: :index)
  end

  def ensure_trainer!
    return if current_user.trainer?(@track)

    render_403(:not_trainer)
  end
end
