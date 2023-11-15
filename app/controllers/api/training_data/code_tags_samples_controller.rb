class API::TrainingData::CodeTagsSamplesController < API::BaseController
  before_action :use_sample, only: :update_tags
  before_action :ensure_trainer!

  def update_tags
    @sample.update!(tags: params[:tags])

    render json: {}
  end

  private
  def use_sample
    @sample = TrainingData::CodeTagsSample.find_by!(uuid: params[:id])
    @track = @sample.track
  rescue ActiveRecord::RecordNotFound
    render_404(:sample_not_found)
  end
end
