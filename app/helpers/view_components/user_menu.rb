module ViewComponents
  class UserMenu < ViewComponent
    def to_s
      # TODO: Cache this component on user.updated_at
      # TODO: Ensure that name/handle/avatar changes touch users.updated_at
      ReactComponents::Dropdowns::Dropdown.new(menu_button: menu_button, menu_items: menu_items)
    end

    private
    def menu_button
      {
        label: "Button to open the profile menu",
        className: "user-menu",
        html: safe_join(
          [
            avatar(current_user) + icon("more-vertical", "Profile Menu")
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
  end
end
