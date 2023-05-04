class Submission::AI::ChatGPT::ProcessHelpRequest
  include Mandate

  initialize_with :submission, :chatgpt_version, :chatgpt_response

  def call
    record = submission.ai_help_records.create!(
      source: "ChatGPT #{chatgpt_version}",
      advice_markdown: chatgpt_response
    )

    Submission::AIHelpRecordsChannel.broadcast!(record, submission.uuid, submission.user)
  end
end
