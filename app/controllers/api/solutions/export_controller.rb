module API
  module Solutions
    class ExportController < BaseController
      before_action :use_exercise

      def index
        zip_file = Exercise::ExportSolutionsToZipFile.(@exercise)
        send_file(zip_file)
      end

      private
      def use_exercise
        @track = Track.find(params[:track_slug])
        return render_track_not_found if @track.blank?

        @exercise = @track.exercises.find(params[:exercise_slug])
        return render_exercise_not_found if @exercise.blank?
      end
    end
  end
end
