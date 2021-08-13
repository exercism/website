module RedirectHelpers
  def wait_for_redirect
    assert_css ".c-loading-overlay.--loading"
    assert_no_css ".c-loading-overlay.--loading"
  end
end
