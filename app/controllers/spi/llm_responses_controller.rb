module SPI
  class LLMResponsesController < BaseController
    RATE_LIMIT_KEY = "__backoff".freeze
    NUM_RETRIES_KEY = "__num_retries".freeze

    def rate_limited
      original_request = params[:original_request].permit!.to_h
      previous_backoff = original_request[RATE_LIMIT_KEY]

      # If there's a specific backup time provided by the LLM
      # then we should use that.
      if params[:backoff_seconds].present?
        backoff = params[:backoff_seconds].to_i

      # Otherwise we want to take the previous backoff time
      # and use an exponential backoff strategy.
      elsif previous_backoff.present?
        backoff = previous_backoff.to_i * 2

      # Or if this is the first retry, start with 1 second.
      else
        backoff = 1
      end

      backoff = [backoff, 360].min # Cap at 1 hour

      new_payload = original_request.merge(
        RATE_LIMIT_KEY => backoff
      )

      LLM::ExecWithPayload.defer(new_payload, wait: backoff)
    end

    def errored
      original_request = params[:original_request].permit!.to_h
      num_retries = original_request[NUM_RETRIES_KEY] || 0

      # We'll give it a fair go, but then we'll give up, leaving us
      # a bugsnag. We probably want to file this away so we can replay
      # it later, but I don't know how/where yet.
      if num_retries >= 5
        exception = RuntimeError.new("LLM request failed after multiple retries: #{params[:error]}")
        return Bugsnag.notify(exception) do |event|
          event.message = "LLM request failed after multiple retries"
          event.severity = "warning",
                           event.add_metadata({ request: original_request, error: params[:error] })
        end
      end

      num_retries += 1
      new_payload = original_request.merge(
        NUM_RETRIES_KEY => num_retries
      )

      # Give it 1 second in case it's something weird with the LLM service.
      LLM::ExecWithPayload.defer(new_payload, wait: num_retries.second)
    end

    def localization_verify_llm_proposal
      proposal = Localization::TranslationProposal.find_by!(uuid: params[:proposal_uuid])
      feedback = JSON.parse(params[:resp], symbolize_names: true)
      proposal.update!(llm_feedback: feedback)

      return unless feedback[:result] == "spam"

      Localization::TranslationProposal::Reject.(proposal, User.find(User::SYSTEM_USER_ID))
      # TODO: Alert iHiD
    end

    def localization_translated
      original = Localization::Original.find_by!(uuid: params[:original_uuid])
      resp = JSON.parse(params[:resp], symbolize_names: true)
      Localization::Translation::UpdateValue.(original.key, params[:locale], resp[:value])
    end
  end
end
