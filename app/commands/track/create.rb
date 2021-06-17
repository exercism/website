class Track
  class Create
    include Mandate

    initialize_with :slug, :attributes

    def call
      Track.create!(slug: slug, **attributes) do |track|
        Github::Team::Create.("#{track.title} maintainers", track.repo)
      end
    rescue ActiveRecord::RecordNotUnique
      Track.find_by!(slug: slug).tap do |track|
        track.update!(attributes)
      end
    end
  end
end
