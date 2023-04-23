class Submission::AI::ChatGPT::ProcessHelpRequest
  include Mandate

  initialize_with :submission, :chatgpt_response

  def call
    # Write a db record
    # Fire a websocket
  end
end
