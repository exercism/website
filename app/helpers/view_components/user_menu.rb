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
      if current_user.profile
        profile_path = Exercism::Routes.profile_path(current_user)
      else
        profile_path = Exercism::Routes.intro_profiles_path
      end

      [
        { html: profile_item, className: "profile" },
        { html: link_to("My Journey", Exercism::Routes.journey_path), className: "opt" },
        { html: link_to("Profile", profile_path), className: "opt" },
        { html: link_to("Settings", "#"), className: "opt" },
        { html: link_to("Sign out", Exercism::Routes.destroy_user_session_path, method: :delete), className: "opt" }
      ]
    end

    def profile_item
      link_to "#" do
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
