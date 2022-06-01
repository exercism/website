class UserTrack
  class Create
    include Mandate

    initialize_with :user, :track

    def call
      ::UserTrack.create_or_find_by!(user:, track:)
    end
  end
end
