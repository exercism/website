module Submission::AI::ChatGPT
  class ProcessRequest
    include Mandate

    initialize_with :submission, :action, :chatgpt_version, :chatgpt_response

    def call
      case action
      when :help
        ProcessHelpRequest.(submission, chatgpt_version, chatgpt_response)
      when :feedback
        # TODO
      else
        raise "Unknown action type. Should be one of [help, feedback]"
      end
    end
  end
end
