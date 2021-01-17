module API
  class ExercisesController < BaseController
    def complete
      begin
        @track = Track.find(params[:track_id])
      rescue StandardError
        return render_404(:track_not_found)
      end

      begin
        @exercise = @track.exercises.find(params[:id])
      rescue StandardError
        return render_404(:exercise_not_found)
      end

      @user_track = UserTrack.for(current_user, @track)
      return render_404(:track_not_joined) unless @user_track

      @solution = Solution.for(current_user, @exercise)
      return render_404(:solution_not_found) unless @solution

      changes = UserTrack::MonitorChanges.(@user_track) do
        Solution::Complete.(@solution, @user_track)
      end

      output = {
        unlocked_exercises: changes[:unlocked_exercises].map do |exercise|
          {
            slug: exercise.slug,
            title: exercise.title,
            icon_name: exercise.icon_name
          }
        end,
        unlocked_concepts: changes[:unlocked_concepts].map do |concept|
          {
            slug: concept.slug,
            name: concept.name
          }
        end,
        concept_progressions: changes[:concept_progressions].map do |data|
          {
            slug: data[:concept].slug,
            name: data[:concept].name,
            from: data[:from],
            to: data[:to],
            total: data[:total]
          }
        end
      }
      render json: output, status: :ok
    end
  end
end
