class Track
  class Create
    include Mandate

    initialize_with :slug, :attributes

    def call
      Track.create_or_find_by!(slug: slug) do |t|
        t.attributes = attributes
      end
    end
  end
end
