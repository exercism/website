module API
  module Solutions
    class ExportController < BaseController
      before_action :use_exercise

      def index
        return render_403(:solutions_export_not_accessible) unless current_user.maintainer? || current_user.admin?

        zip_file = Exercise::ExportSolutionsToZipFile.(@exercise)
        send_file(zip_file)
      end

      private
      def use_exercise
        @track = Track.find_by(slug: params[:track_slug])
        return render_track_not_found if @track.blank?

        @exercise = @track.exercises.find_by(slug: params[:exercise_slug])
        return render_exercise_not_found if @exercise.blank?
      end
    end
  end
end
