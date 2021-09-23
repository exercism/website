class User
  class ResetAccount
    include Mandate

    initialize_with :user

    def call
      reset_tracks!
      reset_mentoring!
      reset_associations!

      user.update(
        reputation: 0,
        roles: [],
        bio: nil,
        avatar_url: nil,
        location: nil,
        pronouns: nil,
        became_mentor_at: nil
      )
    end

    def reset_tracks!
      user.user_tracks.each do |user_track|
        UserTrack::Destroy.(user_track)
      end

      Mentor::Request.where(student_id: user.id).pending.delete_all
      Mentor::Request.where(student_id: user.id).update_all(student_id: User::GHOST_USER_ID)
    end

    def reset_mentoring!
      user.mentor_discussions.update_all(mentor_id: User::GHOST_USER_ID)
      user.mentor_discussion_posts.update_all(user_id: User::GHOST_USER_ID)
      user.mentor_testimonials.update_all(mentor_id: User::GHOST_USER_ID)
    end

    def reset_associations!
      user.profile&.destroy
      user.activities.delete_all
      user.notifications.delete_all
      user.reputation_tokens.delete_all
      user.reputation_periods.delete_all
      user.acquired_badges.delete_all
      user.track_mentorships.delete_all
      user.scratchpad_pages.delete_all
      user.solution_stars.delete_all
    end
  end
end
