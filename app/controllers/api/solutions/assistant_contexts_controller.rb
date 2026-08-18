# Serves the exercise context (instructions, tests, etc) that the
# llm-chat-proxy worker uses to build its prompt. The worker is not a
# logged-in user; it authenticates with the conversation JWT that the
# website minted for this solution.
class API::Solutions::AssistantContextsController < API::BaseController
  skip_before_action :authenticate_user!

  def show
    solution = Solution.find_by!(uuid: params[:solution_uuid])
    return render_403 unless Solution::AssistantConversation::VerifyConversationToken.(bearer_token, solution)

    render json: {
      track: {
        slug: solution.track.slug,
        title: solution.track.title
      },
      exercise: {
        slug: solution.exercise.slug,
        title: solution.exercise.title
      },
      introduction: render_markdown(solution.introduction),
      instructions: render_markdown(solution.instructions),
      tests: solution.test_files.map do |filename, content|
        { filename:, content: }
      end
    }
  rescue ActiveRecord::RecordNotFound
    render_solution_not_found
  end

  private
  def bearer_token
    request.headers['Authorization'].to_s.match(/^Bearer\s+(.+)$/)&.captures&.first
  end

  def render_markdown(text)
    return "" if text.blank?

    Markdown::Render.(text, :text)
  end
end
