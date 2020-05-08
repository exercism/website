class User
  class JoinTrack
    include Mandate

    initialize_with :user, :track

    def call
      ::UserTrack.create!(user: user, track: track)
    end
  end
end
