module ViewComponents
  module Admin
    # The sidebar of the admin section. It lists every page the current user
    # can see, grouped by the access level each page needs. The front page of
    # /admin shows the same groups as cards, using .groups_for.
    class Nav < ViewComponent
      Item = Struct.new(:title, :description, :icon, :path, :controllers, :visible, :external, keyword_init: true) do
        def url = path.is_a?(Symbol) ? Exercism::Routes.send(path) : path
        def visible_to?(user) = visible.nil? || visible.(user)
        def selected?(controller_path) = controllers.include?(controller_path)
      end

      Group = Struct.new(:title, :level, :items, keyword_init: true) do
        def visible_to?(user) = user.public_send("#{level}?")
      end

      GROUPS = [
        Group.new(
          title: "Admin",
          level: :admin,
          items: [
            Item.new(
              title: "Users", icon: "user-group", path: :admin_users_path, controllers: %w[admin/users],
              description: "Look up a user by their email address."
            ),
            Item.new(
              title: "Partners", icon: "supporters", path: :admin_partners_path,
              controllers: %w[admin/partners admin/adverts admin/perks],
              description: "Manage partners, and their adverts and perks."
            ),
            Item.new(
              title: "Mailshots", icon: "envelope", path: :admin_mailshots_path, controllers: %w[admin/mailshots],
              description: "Write emails and send them to groups of users.",
              # The same rule as ApplicationController#ensure_iHiD!
              visible: ->(user) { Rails.env.development? || user.id == User::IHID_USER_ID }
            ),
            Item.new(
              title: "Shadow bans", icon: "warning", path: :moderation_shadow_banned_users_path,
              controllers: %w[moderation/shadow_banned_users],
              description: "Stop people from mentoring without them knowing."
            ),
            Item.new(
              title: "Sidekiq", icon: "queue", path: "/sidekiq", controllers: [], external: true,
              description: "Watch the background job queues. This opens Sidekiq's own dashboard."
            )
          ]
        ),
        Group.new(
          title: "Maintainer admin",
          level: :maintainer_admin,
          items: [
            Item.new(
              title: "Community videos", icon: "community-video", path: :admin_community_videos_path,
              controllers: %w[admin/community_videos],
              description: "Review videos submitted by the community."
            ),
            Item.new(
              title: "Streaming events", icon: "video", path: :admin_streaming_events_path,
              controllers: %w[admin/streaming_events],
              description: "Schedule and feature live streams."
            ),
            Item.new(
              title: "Submissions", icon: "test-runner", path: :admin_submissions_path, controllers: %w[admin/submissions],
              description: "Watch the latest submissions and their tooling runs."
            )
          ]
        ),
        Group.new(
          title: "Maintainer",
          level: :maintainer,
          items: [
            Item.new(
              title: "Site updates", icon: "updates", path: :admin_site_updates_path, controllers: %w[admin/site_updates],
              description: "Post updates that appear on track pages."
            ),
            Item.new(
              title: "Track maintainers", icon: "maintaining", path: :admin_track_maintainers_path,
              controllers: %w[admin/track_maintainers],
              description: "See who maintains each track, and who could."
            ),
            Item.new(
              title: "Track categories", icon: "tracks", path: :admin_track_categories_path,
              controllers: %w[admin/track_categories],
              description: "See whether each track is maintained."
            ),
            Item.new(
              title: "Experimental editor", icon: "editor", path: :admin_experimental_editors_path,
              controllers: %w[admin/experimental_editors],
              description: "Try the editor with experimental features turned on."
            )
          ]
        )
      ].freeze

      # Returns [group, items] pairs for the groups the user can see,
      # with only the items the user can see.
      def self.groups_for(user)
        return [] unless user

        GROUPS.filter_map do |group|
          next unless group.visible_to?(user)

          items = group.items.select { |item| item.visible_to?(user) }
          [group, items] if items.any?
        end
      end

      initialize_with :controller_path

      def to_s
        groups = self.class.groups_for(current_user)
        return "" if groups.empty?

        tag.nav(class: "c-admin-nav", "aria-label": "Admin") do
          safe_join([overview_link, *groups.map { |group, items| group_html(group, items) }])
        end
      end

      private
      def overview_link
        link_html("Overview", "dashboard", Exercism::Routes.admin_root_path, controller_path == "admin/dashboard")
      end

      def group_html(group, items)
        tag.section(class: "group") do
          tag.h2(group.title) +
            tag.ul do
              safe_join(items.map { |item| tag.li(item_link(item)) })
            end
        end
      end

      def item_link(item)
        link_html(item.title, item.icon, item.url, item.selected?(controller_path), external: item.external)
      end

      def link_html(title, icon_name, url, selected, external: false)
        link_to(
          url,
          class: ("selected" if selected),
          "aria-current": ("page" if selected),
          data: (external ? { turbo: false } : {})
        ) do
          graphical_icon(icon_name) + tag.span(title)
        end
      end
    end
  end
end
