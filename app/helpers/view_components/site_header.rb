module ViewComponents
  class SiteHeader < ViewComponent
    extend Mandate::Memoize

    delegate :namespace_name, :controller_name,
      to: :view_context

    def to_s
      tag.header(id: "site-header") do
        tag.div(class: "lg-container container") do
          logo + docs_nav + contextual_section
        end
      end
    end

    def logo
      link_to Exercism::Routes.root_path, class: "exercism-link lg:hidden xl:block" do
        icon "exercism-with-logo-black", "Exercism"
      end
    end

    def contextual_section
      user_signed_in? ? signed_in_section : signed_out_section
    end

    def signed_in_section
      signed_in_nav +
        tag.div(class: "user-section") do
          safe_join(
            [
              new_testimonial_icon,
              new_badge_icon,
              ReactComponents::Dropdowns::Notifications.new.to_s,
              render(ReactComponents::Dropdowns::Reputation.new(current_user)),
              render(ViewComponents::UserMenu.new)
            ]
          )
        end
    end

    def signed_in_nav
      tag.nav(class: 'signed-in') do
        tag.ul do
          si_nav_li("Dashboard", :dashboard, Exercism::Routes.dashboard_path, selected_tab == :dashboard) +
            si_nav_li("Tracks", :tracks, Exercism::Routes.tracks_path, selected_tab == :tracks) +
            si_nav_li("Mentoring", :mentoring, Exercism::Routes.mentoring_inbox_path, selected_tab == :mentoring) +
            si_nav_li("Contribute", :contribute, Exercism::Routes.contributing_root_path, selected_tab == :contributing) +
            si_nav_li("Donate 💜", :contribute, Exercism::Routes.donate_path, selected_tab == :donate)
        end
      end
    end

    def si_nav_li(title, icon_name, url, selected)
      attrs = selected ? { class: "selected", "aria-current": "page" } : {}
      tag.li attrs do
        link_to(graphical_icon(icon_name) + tag.span(title), url)
      end
    end

    def signed_out_section
      safe_join(
        [
          signed_out_nav,
          tag.div(class: "auth-buttons") do
            link_to("Sign up", Exercism::Routes.new_user_registration_path, class: "btn-primary btn-xs") +
              link_to("Log in", Exercism::Routes.new_user_session_path, class: "btn-secondary btn-xs")
          end,
          explore_dropdown
        ]
      )
    end

    def explore_dropdown
      button = {
        label: "Button to open the navigation menu",
        className: "explore-menu",
        extraClassNames: %w[btn-xs btn-enhanced],
        html: safe_join([graphical_icon("hamburger"), tag.span("Explore")])
      }
      items = [
        { html: link_to("Home", Exercism::Routes.root_path), className: "opt site-link" },
        { html: link_to("Language Tracks", Exercism::Routes.tracks_path), className: "opt site-link" },
        { html: link_to("Contribute", Exercism::Routes.contributing_root_path), className: "opt site-link" },
        { html: link_to("Mentoring", Exercism::Routes.mentoring_path), className: "opt site-link" },
        { html: link_to("Donate 💜", Exercism::Routes.donate_path), className: "opt site-link donate" }
      ]
      render(ReactComponents::Dropdowns::Dropdown.new(menu_button: button, menu_items: items))
    end

    def signed_out_nav
      tag.nav(class: 'signed-out') do
        tag.ul do
          safe_join(
            [
              si_nav_li("Home", :home, Exercism::Routes.root_path, selected_tab == :dashboard),
              si_nav_li("Language Tracks", :tracks, Exercism::Routes.tracks_path, selected_tab == :tracks),
              # tag.li { "What is Exercism?", about_page_path )
              si_nav_li("Contribute", :contribute, Exercism::Routes.contributing_root_path, selected_tab == :contributing),
              si_nav_li("Mentor", :mentoring, Exercism::Routes.mentoring_path, selected_tab == :mentoring),
              si_nav_li("Donate 💜", :donate, Exercism::Routes.donate_path, selected_tab == :donate)
            ]
          )
        end
      end
    end

    def docs_nav
      tag.div class: "docs-search" do
        tag.div class: "c-search-bar" do
          tag.input class: "--search", placeholder: "Search Exercism's docs..."
        end
      end
    end

    def new_testimonial_icon
      # TODO: (Optional) Cache this?
      # TODO: (Optional) Add test coverage
      return nil unless current_user.mentor_testimonials.unrevealed.exists?

      link_to('', Exercism::Routes.mentoring_testimonials_path, class: 'new-testimonial')
    end

    def new_badge_icon
      # TODO: (Optional) Cache this?
      # TODO: (Optional) Add test coverage
      return nil unless current_user.acquired_badges.unrevealed.exists?

      link_to('', Exercism::Routes.badges_journey_path(anchor: "journey-content"), class: 'new-badge')
    end

    memoize
    def selected_tab
      if namespace_name == "mentoring"
        :mentoring
      elsif namespace_name == "contributing"
        :contributing
      elsif controller_name == "dashboard"
        :dashboard
      elsif %w[tracks exercises concepts iterations community_solutions mentor_discussions].include?(controller_name)
        :tracks
      end
    end
  end
end
