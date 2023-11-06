class API::TrainingData::CodeTagsSamplesController < API::BaseController
  def update_tags
    sample = TrainingData::CodeTagsSample.find_by!(uuid: params[:id])
    sample.update!(tags: params[:tags])

    render json: {}
  end
end