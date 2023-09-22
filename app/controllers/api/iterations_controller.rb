class API::IterationsController < API::BaseController
  before_action :use_solution
  before_action :guard_solution!, except: [:automated_feedback]
  before_action :use_iteration, only: %i[destroy automated_feedback]

  def latest
    iteration = @solution.iterations.includes(:track, :exercise, :files, :submission).last
    return render_iteration_not_found if iteration.nil?

    sideload = sideload?(:automated_feedback) ? [:automated_feedback] : []
    render json: { iteration: SerializeIteration.(iteration, sideload:) }
  end

  # TOOD: Would it be better to have a status for no iteration status
  # than returning nil?
  def latest_status
    iteration = @solution.iterations.last
    render json: {
      status: iteration ? iteration.status.to_s : nil
    }
  end

  def automated_feedback
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

  def create
    begin
      submission = @solution.submissions.find_by!(uuid: params[:submission_uuid])
    rescue ActiveRecord::RecordNotFound
      return render_submission_not_found
    end

    iteration = Iteration::Create.(@solution, submission)

    render json: {
      iteration: SerializeIteration.(iteration)
    }, status: :created
  end

  def destroy
    Iteration::Destroy.(@iteration)

    render json: {
      iteration: SerializeIteration.(@iteration)
    }
  end

  private
  def use_solution
    @solution = Solution.find_by!(uuid: params[:solution_uuid])
  rescue ActiveRecord::RecordNotFound
    render_solution_not_found
  end

  def use_iteration
    @iteration = @solution.iterations.find_by!(uuid: params[:uuid])
  rescue ActiveRecord::RecordNotFound
    render_iteration_not_found
  end

  def guard_solution!
    render_solution_not_accessible unless @solution.user_id == current_user.id
  end
end
