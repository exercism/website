class Localization::GlossaryEntryProposal
  class CreateDeletion
    include Mandate

    initialize_with :glossary_entry, :user

    def call
      ActiveRecord::Base.transaction do
        Localization::GlossaryEntryProposal.create!(
          type: :deletion,
          glossary_entry: glossary_entry,
          proposer: user
        )
      end
    end
  end
end
