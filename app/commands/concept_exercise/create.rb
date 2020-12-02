class ConceptExercise
  class Create
    include Mandate

    initialize_with :uuid, :track, :attributes

    def call
      ::ConceptExercise.create_or_find_by!(uuid: uuid, track: track) do |ce|
        ce.attributes = attributes
      end
    end
  end
end
