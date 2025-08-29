class Localization::GlossaryEntryProposal::VerifyWithLLM
  include Mandate

  initialize_with :proposal

  def call
    LLM::ExecGeminiFlash.(prompt, endpoint)
  end

  def endpoint
    "localization_verify_glossary_entry_proposal?proposal_uuid=#{proposal.uuid}"
  end

  def prompt
    <<~PROMPT
      You are a localization expert.#{' '}
      Your task is to verify the quality of a glossary entry proposal.
      This glossary entry will be sent to future LLM translators when doing translation work.

      The proposal has three parts:
      - A term in English
      - A proposed translation of that term into the target language
      - Proposed instructions on how the term should be used by the LLM translator in the future

      Respond with JSON containing two fields:
      - `result`: "approved", "rejected" or "spam" based on the quality of the glossary entry.
      - `reason`: A brief explanation of your decision.

      You should use "approved" if the glossary entry is generally accurate and appropriate for the given context.
      You should use "rejected" if the glossary entry has issues such as inaccuracies, poor phrasing, or is not suitable for the context.
      You should use "spam" if the glossary entry is a serious step away from the intended purpose. For example, if it is trying to inject spam onto the website, or contains profanity etc. Use this with care as it will automatically block the user that proposed the change.

      The target locale is `#{proposal.locale}`

      The original glossary term was:
      ~~~~~~
      #{proposal.term}
      ~~~~~~

      This is information about how it's used:
      ~~~~~~
      #{proposal.llm_instructions}
      ~~~~~~

      The proposed glossary entry is:
      ~~~~~~
      #{proposal.translation}
      ~~~~~~

      Respond with JSON.
    PROMPT
  end
end
