module ViewComponents
  module Profile
    class Header < ViewComponent
      initialize_with :user, :profile, :selected_tab

      def to_s
        render "profiles/header",
          user:,
          profile:,
          selected_tab:,
          top_three_tracks:,
          header_tags:
      end

      def top_three_tracks
        track_ids = User::ReputationPeriod.where(
          user: @user,
          period: :forever,
          about: :track,
          category: :any
        ).order(reputation: :desc).limit(3).pluck(:track_id)

        ::Track.active.where(id: track_ids).sort_by { |t| track_ids.index(t.id) }
      end

      def header_tags
        tags = []
        tags << { class: "tag staff", icon: :logo, title: "Exercism Staff" } if @user.staff?
        tags << { class: "tag maintainer", icon: :maintaining, title: "Maintainer" } if @user.maintainer?
        tags << { class: "tag insider", icon: :insiders, title: "Insider" } if @user.insider?
        tags.take(2)
      end
    end
  end
end
