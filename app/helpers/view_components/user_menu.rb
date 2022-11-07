module ViewComponents
  class UserMenu < ViewComponent
    def to_s
      # TODO: (Optional) Cache this component on user.updated_at
      # TODO: (Optional) Ensure that name/handle/avatar changes touch users.updated_at
      ReactComponents::Dropdowns::Dropdown.new(menu_button:, menu_items:)
    end

    private
    def menu_button
      {
        label: "Button to open the profile menu",
        className: "user-menu",
        html: safe_join(
          [
            avatar(current_user),
            icon("more-vertical", "Profile Menu")
          ]
        )
      }
    end

    def menu_items
      profile_path = current_user.profile ?
        Exercism::Routes.profile_path(current_user) :
        Exercism::Routes.intro_profiles_path

      [
        { html: profile_item, className: "profile" },
        { html: reputation_item, className: "reputation" },
        { html: link_to("Dashboard", Exercism::Routes.dashboard_path), className: "opt site-link" },
        { html: link_to("Tracks", Exercism::Routes.tracks_path), className: "opt site-link" },
        { html: link_to("Mentoring", Exercism::Routes.mentoring_inbox_path), className: "opt site-link" },
        { html: link_to("Community", Exercism::Routes.community_path), className: "opt site-link" },
        { html: link_to("Donate 💜", Exercism::Routes.donate_path), className: "opt site-link donate" },
        { html: link_to("Public Profile", profile_path), className: "opt" },
        { html: link_to("Your Journey", Exercism::Routes.journey_path), className: "opt" },
        { html: link_to("Settings", Exercism::Routes.settings_path), className: "opt" },
        { html: link_to("Sign out", Exercism::Routes.destroy_user_session_path, method: :delete), className: "opt" }
      ]
    end

    def profile_item
      profile_path = current_user.profile ?
        Exercism::Routes.profile_path(current_user) :
        Exercism::Routes.intro_profiles_path

      link_to profile_path do
        avatar(current_user, alt: "Your uploaded avatar") +
          tag.div(class: 'info') do
            tag.div(current_user.name, class: 'name') +
              tag.div("@#{current_user.handle}", class: 'handle')
          end +
          icon('external-link', "Open public profile")
      end
    end

    def reputation_item
      render ViewComponents::Reputation.new(current_user.formatted_reputation, flashy: true)
    end
  end
end
