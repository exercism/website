class API::TrainingData::CodeTagsSamplesController < API::BaseController
  def update_tags
    sample = TrainingData::CodeTagsSample.find(params[:id])
    sample.update!(tags: params[:tags])

    render json: {}
  end
end
