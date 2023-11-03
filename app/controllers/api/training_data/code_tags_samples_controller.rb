class API::TrainingData::CodeTagsSamplesController < API::BaseController
  def update
    sample = TrainingData::CodeTagsSample.find_by!(uuid: params[:id])
    sample.id
  end
end
