class Concept
  class Contributorship
    class Create
      include Mandate

      initialize_with :concept, :contributor

      def call
        begin
          contributorship = concept.contributorships.create!(contributor:)
        rescue ActiveRecord::RecordNotUnique
          return nil
        end

        AwardReputationTokenJob.perform_later(
          contributor,
          :concept_contribution,
          contributorship:
        )
      end
    end
  end
end
