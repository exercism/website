require "test_helper"
require_relative "./support/websockets_helpers"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include WebsocketsHelpers
  # Devise::Test::IntegrationHelpers

  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :selenium, using: :headless_chrome do |driver_option|
    # Without this argument, Chrome cannot be started in Docker
    driver_option.add_argument('no-sandbox')
  end

  def sign_in!(user = nil)
    @current_user = user || create(:user)

    # TODO: Renable when adding devise
    # @current_user.confirm
    # sign_in @current_user
  end

  # This adds the within option to assert_text
  # For example:
  # assert_text "Ruby", within: "h3.title"
  def assert_text(text, *args, **options)
    context = options.delete(:within)
    if context
      within(context) { assert_text(text, *args, **options) }
    else
      super
    end
  end

  # This does a string comparison between some given HTML
  # and some HTML found in the document.
  def assert_html(html, within: "body")
    # These save options give us an HTML set that's compatible
    # between capybara and writing HTML.
    nokogiri_save_options = Nokogiri::XML::Node::SaveOptions::FORMAT |
                            Nokogiri::XML::Node::SaveOptions::NO_DECLARATION |
                            Nokogiri::XML::Node::SaveOptions::AS_XHTML

    # Get the html of either the body or the css path
    context = find(:css, within)['innerHTML']

    # Format the passed HTML so that it is in the same format
    # as the HTML retrieved by the line above. To do this we
    # remove any newlines, whitespace between tags,
    # and any leading or trailing whitespace.
    html.gsub!(/\n\s*/, " ")
    html.gsub!(/>\s+</, "><")
    html.gsub!(/^\s+/, "")
    html.gsub!(/\s+$/, "")

    # Format them both in the same manner and indent to zero to remove whitespace
    formatted_html = Nokogiri::XML(html).to_xhtml(indent: 0, save_with: nokogiri_save_options)
    formatted_context = Nokogiri::XML(context).to_xhtml(indent: 0, save_with: nokogiri_save_options)

    # Create a useful and readable error message in case of no match
    error_msg = lambda {
      pretty_html = Nokogiri::XML(html).to_xhtml(indent: 2, save_with: nokogiri_save_options)
      pretty_context = Nokogiri::XML(context).to_xhtml(indent: 2, save_with: nokogiri_save_options)
      "Could not find:\n#{pretty_html}\n...in...#{pretty_context}"
    }

    # Run the assertion
    assert_includes formatted_context, formatted_html, error_msg
  end
end
