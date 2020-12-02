class Track::Concept
  class Create
    include Mandate

    initialize_with :uuid, :track, :attributes

    def call
      Track::Concept.create_or_find_by!(uuid: uuid, track: track) do |c|
        c.attributes = attributes
      end
    end
  end
end
