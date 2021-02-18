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
      if namespace_name == "mentoring"
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
            nav_li("Mentoring", :mentoring, Exercism::Routes.mentoring_dashboard_path, selected == :mentoring) +
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
        safe_join(
          [
            ReactComponents::Dropdowns::Notifications.new.to_s,
            render(ViewComponents::PrimaryReputation.new(current_user, has_notification: true)),
            render(ViewComponents::UserMenu.new)
          ]
        )
      end
    end

    def signed_out_section; end
  end
end
