class SerializeSubmissionAIHelpRecord
  include Mandate

  initialize_with :record

  def call
    return nil unless record

    {
      source: record.source,
      advice_html: record.advice_html
    }
  end
end
