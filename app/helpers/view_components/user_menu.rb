module ViewComponents
  class UserMenu < ViewComponent
    def to_s
      tag.div(class: "user-menu") do
        rounded_bg_img(
          "https://avatars3.githubusercontent.com/u/135246?s=460",
          "#{current_user.name}'s uploaded avatar"
        ) +
          icon("more-vertical", "Profile Menu")
      end
    end
  end
end
