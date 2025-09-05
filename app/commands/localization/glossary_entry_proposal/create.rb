class Localization::GlossaryEntryProposal
  class Create
    include Mandate

    initialize_with :glossary_entry, :user, :value

    def call
      # For existing glossary entries, create a modification proposal
      CreateModification.(glossary_entry, user, value, "")
    end
  end
end
