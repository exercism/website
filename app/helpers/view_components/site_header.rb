module ViewComponents
  class SiteHeader < ViewComponent
    extend Mandate::Memoize

    delegate :render_site_header?,
      :namespace_name, :controller_name,
      to: :view_context

    def to_s
      return unless render_site_header?

      tag.header(id: "site-header") do
        tag.div(class: "lg-container container") do
          logo + nav + contextual_section
        end
      end
    end

    def logo
      link_to Exercism::Routes.root_path, class: "exercism-link" do
        icon "exercism-with-logo-black", "Exercism"
      end
    end

    def nav
      if namespace_name == "mentor"
        selected = :mentoring
      elsif controller_name == "dashboard"
        selected = :dashboard
      else
        selected = :tracks
      end

      tag.nav do
        tag.ul do
          nav_li("Dashboard", :dashboard, Exercism::Routes.dashboard_path, selected == :dashboard) +
            nav_li("Tracks", :tracks, Exercism::Routes.tracks_path, selected == :tracks) +
            nav_li("Mentoring", :mentoring, Exercism::Routes.mentor_dashboard_path, selected == :mentoring) +
            nav_li("Contribute", :logo, "#", false)
        end
      end
    end

    def nav_li(title, icon_name, url, selected)
      if selected
        attrs = {
          class: "selected",
          "aria-current": "page"
        }
      else
        attrs = {}
      end
      tag.li(attrs) do
        link_to url do
          safe_join([
            (icon('bubbly-background', "Selected", css_class: 'selected') if selected),
            graphical_icon(icon_name),
            title
          ].compact)
        end
      end
    end

    def contextual_section
      user_signed_in? ? signed_in_section : signed_out_section
    end

    def signed_in_section
      tag.div(class: "user-section") do
        safe_join([
                    ReactComponents::Common::NotificationsIcon.new(current_user).to_s,
                    render(ViewComponents::PrimaryReputation.new(current_user, has_notification: true)),
                    tag.div(class: "user-menu") do
                      rounded_bg_img(
                        "https://avatars3.githubusercontent.com/u/135246?s=460",
                        "#{current_user.name}'s uploaded avatar"
                      ) +
                      icon("more-vertical", "Profile Menu")
                    end
                  ])
      end
    end

    def signed_out_section; end
  end
end
