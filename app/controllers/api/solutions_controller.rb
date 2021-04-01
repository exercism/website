module API
  class SolutionsController < BaseController
    def index
      solutions = Solution::SearchUserSolutions.(
        current_user,
        criteria: params[:criteria],
        status: params[:status],
        mentoring_status: params[:mentoring_status],
        page: params[:page],
        order: params[:order]
      )

      render json: SerializePaginatedCollection.(
        solutions,
        serializer: SerializeSolutions
      )
    end

    def show
      begin
        solution = Solution.find_by!(uuid: params[:id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      output = {
        solution: SerializeSolution.(solution)
      }
      output[:iterations] = solution.iterations.map { |iteration| SerializeIteration.(iteration) } if sideload?(:iterations)
      render json: output
    end

    def complete
      begin
        solution = Solution.find_by!(uuid: params[:id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      user_track = UserTrack.for(current_user, solution.track)
      return render_404(:track_not_joined) unless user_track

      changes = UserTrack::MonitorChanges.(user_track) do
        Solution::Complete.(solution, user_track)
      end

      output = {
        exercise: {
          slug: solution.exercise.slug,
          title: solution.exercise.title,
          icon_url: solution.exercise.icon_url,
          links: {
            self: Exercism::Routes.track_exercise_path(solution.track, solution.exercise)
          }
        },
        unlocked_exercises: changes[:unlocked_exercises].map do |exercise|
          {
            slug: exercise.slug,
            title: exercise.title,
            icon_url: exercise.icon_url
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

    private
    def set_track
      @track = Track.find_by!(slug: params[:track_id])
    end

    def set_exercise
      @exercise = @track.exercises.find_by!(slug: params[:exercise_id])
    end

    def respond_with_authored_solution(solution)
      solution.update_git_info! unless solution.downloaded?

      render json: SerializeSolutionForCLI.(solution, current_user)

      # Only set this if we've not 500'd
      solution.update(downloaded_at: Time.current)
    end
  end
end
