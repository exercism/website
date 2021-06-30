class UserTrack
  class Reset
    include Mandate

    initialize_with :user_track

    def call
      user_track.solutions.update_all(user_id: User::SYSTEM_USER_ID)
    end
  end
end
