module API
  module Iterations
    class AutomatedFeedbackController < BaseController
      before_action :use_solution

      def show
        @iteration = @solution.iterations.find_by!(uuid: params[:iteration_uuid])

        render json: {
          automated_feedback: {
            representer_feedback: @iteration.representer_feedback,
            analyzer_feedback: @iteration.analyzer_feedback,
            track: SerializeMentorSessionTrack.(@solution.track),
            links: {
              info: Exercism::Routes.doc_path('using', 'feedback/automated')
            }
          }
        }
      end

      private
      def use_solution
        @solution = Solution.find_by!(uuid: params[:solution_uuid])
      rescue ActiveRecord::RecordNotFound
        render_solution_not_found

        # TODO: Allow access for both solution author and mentor.
        # Probably worth implementing User#may_view_solution? now.
        # return render_solution_not_accessible
      end
    end
  end
end
