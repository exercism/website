module ClipboardHelpers
  def assert_clipboard_text(expected)
    page.driver.browser.execute_cdp(
      "Browser.setPermission",
      {
        origin: page.server_url,
        permission: { name: "clipboard-read" },
        setting: "granted"
      }
    )

    actual = page.evaluate_async_script("navigator.clipboard.readText().then(arguments[0])")

    assert_equal expected, actual
  end
end
