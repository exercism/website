module ViewComponents
  class SiteHeader < ViewComponent
    extend Mandate::Memoize

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
      return tag.span("") if current_user&.donated?

      link_to(Exercism::Routes.donate_path, class: "announcement-bar") do
        tag.div(class: "lg-container") do
          tag.span("⚠️ Exercism needs donations to survive 2023. ") +
            tag.strong("Please support us if you can!") +
            tag.span("⚠️")
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
              generic_nav("Learn", LEARN_SUBMENU),
              generic_nav("Contribute", LEARN_SUBMENU, nil, 20),
              generic_nav("Community", LEARN_SUBMENU, nil, 50),
              generic_nav("Resources", LEARN_SUBMENU, nil, 100),
              generic_nav("Premium", LEARN_SUBMENU, nil, 150)
            ]
          )
        end + handle_focus
      end
    end

    # this is neccessary otherwise there would be duplicate, glitchy menus
    def handle_focus
      tag.script do
        <<~JS.html_safe
          document.addEventListener('DOMContentLoaded', function() {
            const navElements = document.querySelectorAll('.nav-element');
            let currentMouseOverElement = null;

            navElements.forEach((navElement) => {
              navElement.addEventListener('mouseover', () => {
                removeFocusFromOtherElements(navElement);
                currentMouseOverElement = navElement;
                document.body.classList.remove('keyboard-navigation');
              });

              navElement.addEventListener('mouseleave', () => {
                currentMouseOverElement = null;
              });

              navElement.addEventListener('focus', () => {
                if (currentMouseOverElement) {
                  const dropdown = currentMouseOverElement.querySelector('.nav-element-dropdown');
                  if (dropdown) {
                    dropdown.classList.add('hidden');
                  }
                }

                removeFocusFromOtherElements(navElement);
              });

              navElement.addEventListener('blur', () => {
                if (currentMouseOverElement) {
                  const dropdown = currentMouseOverElement.querySelector('.nav-element-dropdown');
                  if (dropdown) {
                    dropdown.classList.remove('hidden');
                  }
                }
              });
            });

            function removeFocusFromOtherElements(currentElement) {
              navElements.forEach((otherElement) => {
                if (otherElement !== currentElement) {
                  otherElement.blur();
                  const focusableChildren = otherElement.querySelectorAll('[tabindex="0"]');
                  focusableChildren.forEach((child) => {
                    child.blur();
                  });
                }
              });
            }

            document.addEventListener('keydown', function(event) {
              if (event.key === 'Tab') {
                document.body.classList.add('keyboard-navigation');
              }
            });
          });
        JS
      end
    end

    def generic_nav(nav_title, submenu, path = nil, offset = 0)
      conditional_link(path) do
        tag.li class: 'nav-element', role: 'none' do
          tag.span(nav_title, tabindex: 0) << nav_dropdown(submenu, offset) << css_arrow
        end
      end
    end

    def conditional_link(path = nil)
      content = yield

      if path.nil?
        content
      else
        link_to(path) do
          content
        end
      end
    end

    LEARN_SUBMENU = [
      {
        title: "Tracks",
        description: "Learn 99+ tracks for free forever",
        path: nil,
        icon: :tracks,
        content: ->(tag, instance) { instance.nav_dropdown_tracks_view(tag) }
      },
      {
        title: "Mentoring",
        description: "Get mentored by pros",
        path: nil,
        icon: :mentoring,
        content: ->(tag, instance) { instance.nav_dropdown_mentoring_view(tag) }
      }
    ].freeze

    def css_arrow
      tag.div class: 'arrow'
    end

    def nav_dropdown_tracks_view(tag)
      tag.div class: 'nav-dropdown-view-content' do
        "Track details"
      end
    end

    def nav_dropdown_mentoring_view(tag)
      tag.div class: 'nav-dropdown-view-content' do
        "mentoring details"
      end
    end

    def nav_dropdown(submenu, offset)
      tag.div class: 'nav-element-dropdown', style: "--dropdown-offset: -#{offset}px;", role: 'menu' do
        tag.ul do
          submenu.inject(''.html_safe) do |content, tag_info|
            content << tag.li(
              nav_dropdown_element(tag_info[:title], tag_info[:description], tag_info[:icon]) <<
              nav_dropdown_view(tag_info[:content].(tag, self))
            )
          end
        end
      end
    end

    def nav_dropdown_element(title, description, icon)
      tag.div(class: "nav-dropdown-element", tabindex: 0, role: 'menuitem') do
        graphical_icon(icon) <<
          tag.div do
            tag.h6(title) << tag.p(description)
          end
      end
    end

    def nav_dropdown_view(element)
      tag.div(class: 'nav-dropdown-view') do
        element
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
      tag.nav(class: 'signed-out') do
        tag.ul do
          safe_join(
            [
              si_nav_li("Home", :home, Exercism::Routes.root_path, selected_tab == :dashboard),
              si_nav_li("Language Tracks", :tracks, Exercism::Routes.tracks_path, selected_tab == :tracks),
              si_nav_li("Community", :community, Exercism::Routes.community_path, selected_tab == :community),
              si_nav_li("Mentor", :mentoring, Exercism::Routes.mentoring_path, selected_tab == :mentoring),
              si_nav_li("Insiders 💜", :insiders, Exercism::Routes.insiders_path, selected_tab == :insiders),
              si_nav_li("Donate", :donate, Exercism::Routes.donate_path, selected_tab == :donate)
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
