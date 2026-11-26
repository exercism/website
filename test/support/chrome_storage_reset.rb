# Chrome 158 rejects "*" as an origin for Storage.clearDataForOrigin, which
# Capybara 3.40 sends when it resets the session after every system test. The
# reset then raises "* is not a valid URL" and the test errors.
#
# This swaps that one call for two Chrome accepts: clear every cookie, then
# clear the other storage types for the test server's own origin, which is the
# only origin a test writes to.
module ChromeStorageReset
  def execute_cdp(cmd, params = {})
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    super("Network.clearBrowserCookies")

    storage_types = params[:storageTypes].to_s.split(",") - ["cookies"]
    server = Capybara.current_session.server
    return if storage_types.empty? || server.nil?

    super("Storage.clearDataForOrigin", origin: server.base_url, storageTypes: storage_types.join(","))
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageReset)
