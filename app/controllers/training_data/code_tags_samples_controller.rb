class TrainingData::CodeTagsSamplesController < ApplicationController
  before_action :use_track, only: [:next]

  def index; end

  def show
    @sample = TrainingData::CodeTagsSample.first
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

  def use_track
    @track = Track.find(params[:track_id])
  rescue StandardError
    redirect_to(action: :index)
  end
end
