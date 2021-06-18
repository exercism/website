class Track
  class Create
    include Mandate

    initialize_with :slug, :attributes

    def call
      Track.create!(slug: slug, **attributes).tap do |track|
        ContributorTeam::Create.("#{track.title} maintainers", github_name: track.slug, type: :track_maintainers,
                                                               track: track)
      end
    rescue ActiveRecord::RecordNotUnique
      Track.find_by!(slug: slug).tap do |track|
        track.update!(attributes)
      end
    end
  end
end
