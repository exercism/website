module ViewComponents
  module Profile
    class Header < ViewComponent
      initialize_with :user, :profile, :selected_tab

      def to_s
        render "profiles/header",
          user: user,
          profile: profile,
          selected_tab: selected_tab,
          top_three_tracks: top_three_tracks
      end

      def top_three_tracks
        track_ids = @user.reputation_tokens.
          joins(:track).
          where("tracks.active": true).
          group(:track_id).
          select("track_id, COUNT(*) as c").
          order("c DESC").
          limit(3).map(&:track_id)

        ::Track.where(id: track_ids).
          order(Arel.sql("FIND_IN_SET(id, '#{track_ids.join(',')}')"))
      end
    end
  end
end
