class Submission::AI::ChatGPT::ProcessHelpRequest
  include Mandate

  initialize_with :submission, :chatgpt_response

  def call
    record = submission.ai_help_records.create!(
      source: "chatgpt",
      advice_markdown: chatgpt_response
    )

    Submission::AIHelpRecordsChannel.broadcast!(record, submission.uuid)
  end
end
