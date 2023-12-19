require "test_helper"
require_relative "./support/websockets_helpers"
require_relative "./support/capybara_helpers"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include WebsocketsHelpers
  include CapybaraHelpers
  include Devise::Test::IntegrationHelpers

  # Temporary fix: https://github.com/titusfortner/webdrivers/issues/247
  # Webdrivers::Chromedriver.required_version = "116.0.5845.96"
  Capybara.default_max_wait_time = 7
  Capybara.enable_aria_label = true
  Capybara.reuse_server = false
  # Capybara.disable_animation = true

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
    # Reset logs regardless of status
    errors = page.driver.browser.logs.get(:browser)

    # Reset everything
    Capybara.reset_sessions!
    Capybara.use_default_driver

    # Don't do anything else if we're deliberately not flunking
    return if ApplicationSystemTestCase.override_should_flunk

    should_flunk = false
    errors.to_a.each do |error|
      next if error.level == "WARNING"
      next if error.to_s.include?("403 (Forbidden)")
      next if error.to_s.include?("hcaptcha")
      next if error.to_s.include?("js.stripe.com")
      next if error.to_s.include?("https://test.exercism.org/rails/active_storage/representations/redirect")

      should_flunk = true

      puts ""
      puts "------"
      puts "JS ERROR:\n"
      puts error
      puts "------"
      puts ""
    end

    flunk("JS Errors") if should_flunk
  end

  Capybara.register_driver :selenium_chrome_headless do |app|
    options = Selenium::WebDriver::Chrome::Options.new(args: %w[headless window-size=1400,1000])

    options.add_argument("headless=new")

    # Specify the download directory to allow retrieving files in system tests
    options.add_preference("download.default_directory", TestHelpers.download_dir.to_s)

    # Without this argument, Chrome cannot be started in Docker
    options.add_argument('no-sandbox')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
  end

  driven_by(:selenium_chrome_headless)

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

  def assert_text(text, **options)
    options[:normalize_ws] = true unless options.key?(:normalize_ws)
    super(:visible, text, **options)
  end

  def url_to_path(url)
    url.gsub(%r{https?://[^/]+}, "")
  end
end
