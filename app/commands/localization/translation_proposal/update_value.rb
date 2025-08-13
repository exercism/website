class Localization::TranslationProposal::UpdateValue
  include Mandate

  initialize_with :proposal, :user, :value

  def call
    proposal.update!(value: value)
  end
end
