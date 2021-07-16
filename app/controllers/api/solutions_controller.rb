module API
  class SolutionsController < BaseController
    def index
      solutions = Solution::SearchUserSolutions.(
        current_user,
        criteria: params[:criteria],
        track_slug: params[:track_slug],
        status: params[:status],
        mentoring_status: params[:mentoring_status],
        page: params[:page],
        per: params[:per_page],
        order: params[:order]
      )

      render json: SerializePaginatedCollection.(
        solutions,
        serializer: SerializeSolutions,
        serializer_args: [current_user]
      )
    end

    def show
      begin
        solution = Solution.find_by!(uuid: params[:uuid])
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
        solution = Solution.find_by!(uuid: params[:uuid])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      user_track = UserTrack.for(current_user, solution.track)
      return render_404(:track_not_joined) if user_track.external?

      changes = UserTrack::MonitorChanges.(user_track) do
        Solution::Complete.(solution, user_track)
        Solution::Publish.(solution, params[:iteration_idx]) if params[:publish]
      end

      output = {
        track: SerializeTrack.(solution.track, user_track),
        exercise: SerializeExercise.(solution.exercise, user_track: user_track),
        unlocked_exercises: changes[:unlocked_exercises].map do |exercise|
          SerializeExercise.(exercise, user_track: user_track)
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

    def publish
      begin
        solution = Solution.find_by!(uuid: params[:uuid])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      # TODO: (Required) Add check if solution is not complete

      return render_solution_not_accessible unless solution.user_id == current_user.id

      user_track = UserTrack.for(current_user, solution.track)
      return render_404(:track_not_joined) if user_track.external?

      Solution::Publish.(solution, params[:iteration_idx])

      render json: {
        solution: SerializeSolution.(solution)
      }, status: :ok
    end

    def published_iteration
      begin
        solution = Solution.find_by!(uuid: params[:uuid])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end
      return render_solution_not_accessible unless solution.user_id == current_user.id

      user_track = UserTrack.for(current_user, solution.track)
      return render_404(:track_not_joined) if user_track.external?

      solution.update!(published_iteration: solution.iterations.find_by(idx: params[:published_iteration_idx]))

      render json: {
        solution: SerializeSolution.(solution)
      }, status: :ok
    end

    def unpublish
      begin
        solution = Solution.find_by!(uuid: params[:uuid])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      # TODO: (Required): Add check if solution is not complete

      return render_solution_not_accessible unless solution.user_id == current_user.id

      user_track = UserTrack.for(current_user, solution.track)
      return render_404(:track_not_joined) if user_track.external?

      solution.update!(published_at: nil, published_iteration_id: nil)

      render json: {
        solution: SerializeSolution.(solution)
      }, status: :ok
    end

    def diff
      begin
        solution = Solution.find_by!(uuid: params[:uuid])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end
      return render_solution_not_accessible unless solution.user_id == current_user.id

      render json: {
        diff: {
          exercise: {
            title: solution.exercise.title,
            icon_url: solution.exercise.icon_url
          },
          files: Git::GenerateDiffBetweenExerciseVersions.(solution.exercise, solution.git_slug, solution.git_sha),
          links: {
            update: Exercism::Routes.sync_api_solution_url(solution.uuid)
          }
        }
      }
    end

    def sync
      begin
        solution = Solution.find_by!(uuid: params[:uuid])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end
      return render_solution_not_accessible unless solution.user_id == current_user.id

      solution.sync_git!
      submission = solution.iterations.last&.submission
      Submission::TestRun::Init.(submission) if submission

      render json: { solution: SerializeSolution.(solution) }
    end

    private
    def set_track
      @track = Track.find(params[:track_slug])
    end

    def set_exercise
      @exercise = @track.exercises.find(params[:exercise_slug])
    end

    def respond_with_authored_solution(solution)
      solution.sync_git! unless solution.downloaded?

      render json: SerializeSolutionForCLI.(solution, current_user)

      # Only set this if we've not 500'd
      solution.update(downloaded_at: Time.current)
    end
  end
end
