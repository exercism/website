class Concept
  class Contributorship
    class Create
      include Mandate

      initialize_with :concept, :contributor

      def call
        begin
          contributorship = concept.contributorships.create!(contributor: contributor)
        rescue ActiveRecord::RecordNotUnique
          return nil
        end

        User::ReputationToken::Create.(
          contributor,
          :concept_contribution,
          contributorship: contributorship
        )
      end
    end
  end
end
