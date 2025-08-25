class Localization::TranslationProposal::VerifyWithLLM
  include Mandate

  initialize_with :proposal

  def call
    LLM::ExecGeminiFlash.(prompt, endpoint)
  end

  def endpoint
    "localization_verify_llm_proposal?proposal_uuid=#{proposal.uuid}"
  end

  def prompt
    <<~PROMPT
      You are a localization expert. Your task is to verify the quality of a translation proposal.

      Respond with JSON containing two fields:
      - `result`: "approved", "rejected" or "spam" based on the quality of the translation.
      - `reason`: A brief explanation of your decision.

      You should use "approved" if the quality of translation is generally ok, and all placeholders are EXACTLY the same as in the original.
      You should use "rejected" if the translation has serious issues that need to be fixed, such as grammatical or spelling mistakes, or ANY placeholders have changed.
      You should use "spam" if the translation is a serious step away from the original. For example, if it is trying to inject spam onto the website, or contains profanity etc. Use this with care as it will automatically block the user that proposed the change.

      The target locale is `#{locale}`

      The original English text was:
      ~~~~~~
      #{original.value}
      ~~~~~~

      This is information about how it's used:
      ~~~~~~
      #{original.context}
      ~~~~~~

      The proposed translation is:
      ~~~~~~
      #{proposal.value}
      ~~~~~~

      Respond with JSON.
    PROMPT
  end

  delegate :translation, to: :proposal
  delegate :original, to: :translation
  delegate :locale, to: :translation
end
