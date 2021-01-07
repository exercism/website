module ViewComponents
  class UserMenu < ViewComponent
    def to_s
      tag.div(class: "user-menu", data: { dropdown_type: :profile, prerendered: profile_menu_dropdown }) do
        rounded_bg_img(
          "https://avatars3.githubusercontent.com/u/135246?s=460",
          "#{current_user.name}'s uploaded avatar"
        ) +
          icon("more-vertical", "Profile Menu")
      end
    end

    private
    def profile_menu_dropdown
      tag.nav do
        tag.ul do
          tag.li("My Journey") +
            tag.li("Profile") +
            tag.li("Settings") +
            tag.li("Sign out")
        end
      end
    end
  end
end
