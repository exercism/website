require "test_helper"
require_relative "./support/websockets_helpers"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include WebsocketsHelpers
  include Devise::Test::IntegrationHelpers

  Capybara.default_max_wait_time = 5
  Capybara.enable_aria_label = true
  Capybara.reuse_server = false

  class << self
    attr_accessor :override_should_flunk
  end

  def setup
    ApplicationSystemTestCase.override_should_flunk = false

    super
  end

  def expecting_errors
    ApplicationSystemTestCase.override_should_flunk = true

    yield
  end

  def teardown
    if ApplicationSystemTestCase.override_should_flunk
      # reset logs
      page.driver.browser.manage.logs.get(:browser)

      Capybara.reset_sessions!
      Capybara.use_default_driver

      return
    end

    should_flunk = false
    errors = page.driver.browser.manage.logs.get(:browser)
    errors.to_a.each do |error|
      next if error.level == "WARNING"
      next if error.to_s.include?("403 (Forbidden)")
      next if error.to_s.include?("hcaptcha")

      should_flunk = true

      puts ""
      puts "------"
      puts "JS ERROR:\n"
      puts error
      puts "------"
      puts ""
    end

    flunk("JS Errors") if should_flunk

    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  # driven_by :selenium, using: :headless_chrome do |driver_option|
  #   # Without this argument, Chrome cannot be started in Docker
  #   driver_option.add_argument('no-sandbox')
  # end

  def sign_in!(user = nil)
    @current_user = user || create(:user)
    @current_user.auth_tokens.create! if @current_user.auth_tokens.blank?

    @current_user.confirm
    sign_in @current_user
  end

  # As we only use #page- prefix on ids for pages
  # this is a safe way of checking we've been positioned
  # on the right page during tests
  def assert_page(page)
    assert_css "#page-#{page}"
  end

  # This adds the within option to assert_text
  # For example:
  # assert_text "Ruby", within: "h3.title"
  def assert_text(text, *args, **options)
    # For reasons that none of us understand, We need to explicitely
    # call the body method before the assertion.
    body

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
