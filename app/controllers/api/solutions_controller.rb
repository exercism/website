class API::SolutionsController < API::BaseController
  before_action :use_solution, except: :index
  before_action :use_user_track, only: %i[complete publish published_iteration unpublish]

  def index
    solutions = Solution::SearchUserSolutions.(
      current_user,
      criteria: params[:criteria],
      track_slug: params[:track_slug],
      status: params[:status],
      mentoring_status: params[:mentoring_status],
      sync_status: params[:sync_status],
      tests_status: params[:tests_status],
      head_tests_status: params[:head_tests_status],
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
    output = {
      solution: SerializeSolution.(@solution)
    }
    output[:iterations] = SerializeIterations.(@solution.iterations) if sideload?(:iterations)
    render json: output
  end

  def complete
    changes = UserTrack::MonitorChanges.(@user_track) do
      Solution::Complete.(@solution, @user_track)
      Solution::Publish.(@solution, @user_track, params[:iteration_idx]) if params[:publish]
    rescue SolutionHasNoIterationsError
      return render_400(:solution_without_iterations)
    end

    output = {
      track: SerializeTrack.(@solution.track, @user_track),
      exercise: SerializeExercise.(@solution.exercise, user_track: @user_track),
      unlocked_exercises: changes[:unlocked_exercises].map do |exercise|
        SerializeExercise.(exercise, user_track: @user_track)
      end,
      unlocked_concepts: changes[:unlocked_concepts].map do |concept|
        {
          slug: concept.slug,
          name: concept.name,
          links: {
            self: Exercism::Routes.track_concept_path(concept.track, concept)
          }
        }
      end,
      concept_progressions: changes[:concept_progressions].map do |data|
        {
          slug: data[:concept].slug,
          name: data[:concept].name,
          from: data[:from],
          to: data[:to],
          total: data[:total],
          links: {
            self: Exercism::Routes.track_concept_path(data[:concept].track, data[:concept])
          }
        }
      end
    }
    render json: output, status: :ok
  end

  def publish
    begin
      Solution::Publish.(@solution, @user_track, params[:iteration_idx])
    rescue SolutionHasNoIterationsError
      return render_400(:solution_without_iterations)
    end

    render json: {
      solution: SerializeSolution.(@solution)
    }, status: :ok
  end

  def published_iteration
    Solution::PublishIteration.(@solution, params[:published_iteration_idx])

    render json: {
      solution: SerializeSolution.(@solution)
    }, status: :ok
  end

  def unpublish
    @solution.update!(published_at: nil, published_iteration_id: nil)

    render json: {
      solution: SerializeSolution.(@solution)
    }, status: :ok
  end

  def diff
    files = Git::Exercise::GenerateDiffBetweenVersions.(@solution.exercise, @solution.git_slug, @solution.git_sha)

    # TODO: (Optional): Change this to always be a 200 and handle the empty files in React
    if files.present?
      status = 200
    else
      status = 400
      Bugsnag.notify(RuntimeError.new("No files were found during solution diff"))
    end

    render json: {
      diff: {
        exercise: {
          title: @solution.exercise.title,
          icon_url: @solution.exercise.icon_url
        },
        files:,
        links: {
          update: Exercism::Routes.sync_api_solution_url(@solution.uuid)
        }
      }
    }, status:
  end

  def sync
    Solution::UpdateToLatestExerciseVersion.(@solution)

    render json: { solution: SerializeSolution.(@solution) }
  end

  def unlock_help
    begin
      Solution::UnlockHelp.(@solution)
    rescue SolutionCannotBeUnlockedError
      return render_400(:solution_unlock_help_not_accessible)
    end

    render json: {}
  end

  private
  def use_solution
    @solution = Solution.find_by!(uuid: params[:uuid])

    render_solution_not_accessible unless @solution.user_id == current_user.id
  rescue ActiveRecord::RecordNotFound
    render_solution_not_found
  end

  def use_user_track
    @user_track = UserTrack.for(current_user, @solution.track)
    render_404(:track_not_joined) if @user_track.external?
  end
end
