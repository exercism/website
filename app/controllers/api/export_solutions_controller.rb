class API::ExportSolutionsController < API::BaseController
  before_action :ensure_maintainer!
  before_action :use_track
  before_action :use_exercise

  def index
    zip_file_stream = Exercise::ExportSolutionsToZipFile.(@exercise)
    send_data zip_file_stream, type: 'application/zip', filename: 'solutions.zip'
  end

  private
  def use_track
    @track = Track.find(params[:track_slug])
  rescue ActiveRecord::RecordNotFound
    render_track_not_found
  end

  def use_exercise
    @exercise = @track.exercises.find(params[:exercise_slug])
  rescue ActiveRecord::RecordNotFound
    render_exercise_not_found
  end
end
