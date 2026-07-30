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
        label: I18n.t("components.user_menu.button_label"),
        className: "user-menu",
        html: safe_join(
          [
            avatar(current_user),
            icon("more-vertical", I18n.t("components.user_menu.profile_menu_icon"))
          ]
        )
      }
    end

    def menu_items
      profile_path = current_user.profile? ?
        Exercism::Routes.profile_path(current_user) :
        Exercism::Routes.intro_profiles_path

      [
        { html: profile_item, className: "profile" },
        { html: reputation_item, className: "reputation" },
        { html: link_to(I18n.t("components.user_menu.items.dashboard"), Exercism::Routes.dashboard_path), className: "opt site-link" },
        { html: link_to(I18n.t("components.user_menu.items.tracks"), Exercism::Routes.tracks_path), className: "opt site-link" },
        { html: link_to(I18n.t("components.user_menu.items.mentoring"), Exercism::Routes.mentoring_inbox_path),
          className: "opt site-link" },
        { html: link_to(I18n.t("components.user_menu.items.community"), Exercism::Routes.community_path),
          className: "opt site-link" },
        { html: link_to(I18n.t("components.user_menu.items.insiders"), Exercism::Routes.insiders_path),
          className: "opt site-link" },
        { html: link_to(I18n.t("components.user_menu.items.donate"), Exercism::Routes.donate_path),
          className: "opt site-link donate" },
        { html: link_to(I18n.t("components.user_menu.items.public_profile"), profile_path), className: "opt" },
        { html: link_to(I18n.t("components.user_menu.items.your_journey"), Exercism::Routes.journey_path), className: "opt" },
        { html: link_to(I18n.t("components.user_menu.items.settings"), Exercism::Routes.settings_path), className: "opt" },
        (if current_user.maintainer?
           { html: link_to(I18n.t("components.user_menu.items.maintaining"), Exercism::Routes.maintaining_root_path),
             className: "opt" }
         end),
        { html: button_to(I18n.t("components.user_menu.items.sign_out"), Exercism::Routes.destroy_user_session_path,
          form: { id: "sign-out-form" }, method: :delete),
          className: "opt" }
      ].compact
    end

    def profile_item
      profile_path = current_user.profile? ?
        Exercism::Routes.profile_path(current_user) :
        Exercism::Routes.intro_profiles_path

      link_to profile_path do
        avatar(current_user, alt: I18n.t("components.user_menu.avatar_alt")) +
          tag.div(class: 'info') do
            tag.div(current_user.name, class: 'name') +
              tag.div(class: "handle flex") do
                tag.span("@") + render(ViewComponents::HandleWithFlair.new(current_user.handle, current_user.flair,
                  size: :small)).html_safe
              end
          end +
          icon('external-link', I18n.t("components.user_menu.open_public_profile"))
      end
    end

    def reputation_item
      render ViewComponents::Reputation.new(current_user.formatted_reputation, flashy: true)
    end
  end
end
