class Concept
  class Authorship
    class Create
      include Mandate

      initialize_with :concept, :author

      def call
        begin
          authorship = concept.authorships.create!(author:)
        rescue ActiveRecord::RecordNotUnique
          return nil
        end

        AwardReputationTokenJob.perform_later(
          author,
          :concept_author,
          authorship:
        )
      end
    end
  end
end
