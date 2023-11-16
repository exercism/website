class TrainingData::CodeTagsSamplesController < ApplicationController
  before_action :use_track, only: [:next]
  before_action :use_sample, only: [:show]
  before_action :ensure_trainer!

  def index; end

  def show
    return render_403(:not_trainer) unless current_user.trainer?(@sample.track)
  end

  def next
    status = params[:status] || :untagged
    sample = TrainingData::CodeTagsSample.unlocked.where(
      track: @track,
      status:
    ).first

    raise unless sample

    sample.lock_for_editing!(current_user)

    redirect_to action: :show, id: sample.id
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
