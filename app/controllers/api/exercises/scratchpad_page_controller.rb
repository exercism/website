module API
  module Exercises
    class ScratchpadPageController < BaseController
      before_action :use_exercise

      def create
        page = ScratchpadPage.create!(scratchpad_page_params)

        render json: SerializeScratchpadPage.(page)
      end

      private
      def use_exercise
        track = Track.find_by(slug: params[:track_id])

        return render_404(:track_not_found, fallback_url: tracks_url) if track.blank?

        @exercise = track.exercises.find_by(slug: params[:exercise_id])

        return render_404(:exercise_not_found, fallback_url: track_url(track)) if @exercise.blank?
      end

      def scratchpad_page_params
        params.require(:scratchpad_page).permit(:content_markdown).merge(about: @exercise, author: current_user)
      end
    end
  end
end
