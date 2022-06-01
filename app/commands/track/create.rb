class Track
  class Create
    include Mandate

    initialize_with :slug, :attributes

    def call
      Track.create!(slug:, **attributes).tap do |track|
        ContributorTeam::Create.(track.slug, type: :track_maintainers, track:)
      end
    rescue ActiveRecord::RecordNotUnique
      Track.find_by!(slug:)
    end
  end
end
