module ViewComponents
  class SiteHeader < ViewComponent
    extend Mandate::Memoize
    include ViewComponents::NavHelpers::All
    # include ViewComponents::ThemeToggleButton

    delegate :namespace_name, :controller_name,
      to: :view_context

    def to_s
      tag.header(id: "site-header") do
        announcement_bar +
          tag.div(class: "lg-container container") do
            logo + docs_nav + contextual_section
          end
      end
    end

    def announcement_bar
      return tag.span("") if !user_signed_in? ||
                             current_user.donated? ||
                             current_user.solutions.count < 3

      link_to(Exercism::Routes.insiders_path, class: "announcement-bar md:block hidden") do
        tag.div(class: "lg-container") do
          tag.span("👋", class: 'emoji mr-6') +
            tag.span("Enjoying Exercism? We need your help to survive…") +
            tag.strong("Please support us if you can!")
        end
      end
    end

    def logo
      link_to Exercism::Routes.root_path, class: "exercism-link xl:block", "data-turbo-frame": "tf-main" do
        icon("exercism-with-logo-black", "Exercism")
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
      tag.nav(class: 'signed-in', role: 'navigation') do
        tag.ul do
          safe_join(
            [
              generic_nav("Learn", submenu: LEARN_SUBMENU, path: Exercism::Routes.tracks_path, has_view: true),
              generic_nav("Discover", submenu: DISCOVER_SUBMENU, path: Exercism::Routes.community_path, offset: 20),
              generic_nav("Contribute", submenu: CONTRIBUTE_SUBMENU, path: Exercism::Routes.contributing_root_path, offset: 20),
              generic_nav("More", submenu: MORE_SUBMENU, offset: 0),
              generic_nav("Insiders", path: Exercism::Routes.insiders_path, offset: 150,
                has_view: true, view: (current_user&.insider? ? nil : :insiders),
                css_class: "insiders"),
              ReactComponents::Common::ThemeToggleButton.new(user: current_user)
            ]
          )
        end
      end
    end

    def si_nav_li(title, _icon_name, url, selected)
      attrs = selected ? { class: "selected", "aria-current": "page" } : {}
      tag.li attrs do
        elems = [tag.span(title)]
        # if new
        #   elems << (tag.div(class: 'ml-8 text-warning bg-lightOrange px-8 py-6 rounded-100 font-semibold text-[13px] flex items-center') do # rubocop:disable Layout/LineLength
        #     graphical_icon('sparkle', css_class: '!filter-warning !w-[12px] !h-[12px] !mr-4 !block') +
        #     tag.span("New")
        #   end)
        # end
        link_to(safe_join(elems), url, "data-turbo-frame": "tf-main", class: 'relative')
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
        { html: link_to("Home", Exercism::Routes.root_path, "data-turbo-frame": "tf-main"), className: "opt site-link" },
        { html: link_to("Language Tracks", Exercism::Routes.tracks_path, "data-turbo-frame": "tf-main"), className: "opt site-link" },
        { html: link_to("Community", Exercism::Routes.community_path, "data-turbo-frame": "tf-main"), className: "opt site-link" },
        { html: link_to("Mentoring", Exercism::Routes.mentoring_path, "data-turbo-frame": "tf-main"), className: "opt site-link" },
        { html: link_to("Insiders 💜", Exercism::Routes.insiders_path, "data-turbo-frame": "tf-main"), className: "opt site-link" },
        { html: link_to("Donate", Exercism::Routes.donate_path, "data-turbo-frame": "tf-main"), className: "opt site-link donate" }
      ]
      render(ReactComponents::Dropdowns::Dropdown.new(menu_button: button, menu_items: items))
    end

    def signed_out_nav
      tag.nav(role: 'navigation') do
        tag.ul do
          safe_join(
            [
              generic_nav("Learn", submenu: LEARN_SUBMENU, path: Exercism::Routes.tracks_path),
              generic_nav("Discover", submenu: DISCOVER_SUBMENU, path: Exercism::Routes.community_path, offset: 20),
              generic_nav("Contribute", submenu: CONTRIBUTE_SUBMENU, path: Exercism::Routes.contributing_root_path, offset: 20),
              generic_nav("More", submenu: MORE_SUBMENU, offset: 0)
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
      # TODO: (Optional) Add test coverage
      return nil unless current_user.has_unrevealed_testimonials?

      link_to('', Exercism::Routes.mentoring_testimonials_path, class: 'new-testimonial')
    end

    def new_badge_icon
      # TODO: (Optional) Add test coverage
      return nil unless current_user.has_unrevealed_badges?

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
