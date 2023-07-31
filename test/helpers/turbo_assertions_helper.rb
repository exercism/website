module TurboAssertionsHelper
  TURBO_VISIT = /Turbo\.visit\("([^"]+)", {"action":"([^"]+)"}\)/

  def assert_redirected_to(options = {}, message = nil)
    if turbo_request?
      assert_turbo_visited(options, message)
    else
      super
    end
  end

  def assert_turbo_visited(options = {}, message = nil)
    assert_response(:ok, message)
    assert_equal("text/javascript", response.try(:media_type) || response.content_type)

    visit_location, = turbo_visit_location_and_action

    redirect_is       = normalize_argument_to_redirection(visit_location)
    redirect_expected = normalize_argument_to_redirection(options)

    message ||= "Expected response to be a Turbo visit to <#{redirect_expected}> but was a visit to <#{redirect_is}>"
    assert_operator redirect_expected, :===, redirect_is, message
  end

  # Rough heuristic to detect whether this was a Turbolinks request:
  # non-GET request with a text/javascript response.
  #
  # Technically we'd check that Turbolinks-Referrer request header is
  # also set, but that'd require us to pass the header from post/patch/etc
  # test methods by overriding them to provide a `turbo:` option.
  #
  # We can't check `request.xhr?` here, either, since the X-Requested-With
  # header is cleared after controller action processing to prevent it
  # from leaking into subsequent requests.
  def turbo_request?
    !request.get? && (response.try(:media_type) || response.content_type) == "text/javascript"
  end

  def turbo_visit_location_and_action
    [Regexp.last_match(1), Regexp.last_match(2)] if response.body =~ TURBO_VISIT
  end
end
