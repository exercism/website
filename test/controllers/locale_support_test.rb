# frozen_string_literal: true

require "test_helper"

class LocaleSupportTest < ActiveSupport::TestCase
  class DummyController < ApplicationController
    include LocaleSupport

    attr_reader :request, :default_locale

    def initialize(request:, default_locale:)
      super
      @request = request
      @default_locale = default_locale
    end
  end

  def setup
    @request = mock
    @helper = DummyController.new(request: @request, default_locale: "en")
  end

  # ---- Without loop-breaker ----
  test "without loop-breaker: returns '/' for root with default locale when path_only" do
    assert_equal "/", @helper.url_for_locale("en", "/", path_only: true, add_loop_breaker_query_param: false)
  end

  test "without loop-breaker: returns host only for root with default locale" do
    @request.stubs base_url: "https://exercism.org"
    assert_equal "https://exercism.org", @helper.url_for_locale("en", "/", path_only: false, add_loop_breaker_query_param: false)
  end

  test "without loop-breaker: prefixes locale for root when non-default" do
    @request.stubs base_url: "https://exercism.org"
    assert_equal "/fr", @helper.url_for_locale("fr", "/", path_only: true, add_loop_breaker_query_param: false)
    assert_equal "https://exercism.org/fr", @helper.url_for_locale("fr", "/", path_only: false, add_loop_breaker_query_param: false)
  end

  test "without loop-breaker: strips trailing slashes from paths" do
    assert_equal "/foo", @helper.url_for_locale("en", "/foo/", add_loop_breaker_query_param: false, path_only: true)
    assert_equal "/fr/foo/bar", @helper.url_for_locale("fr", "/foo/bar/", add_loop_breaker_query_param: false, path_only: true)
  end

  test "without loop-breaker: drops existing locale segment" do
    assert_equal "/fr/foo", @helper.url_for_locale("fr", "/en/foo", add_loop_breaker_query_param: false, path_only: true)
  end

  test "without loop-breaker: preserves query params" do
    url = @helper.url_for_locale("fr", "/foo/bar?a=1&b=2", path_only: true, add_loop_breaker_query_param: false)
    assert_match %r{^/fr/foo/bar\?(.*a=1.*&.*b=2.*|.*b=2.*&.*a=1.*)}, url
  end

  # ---- With loop-breaker (default) ----
  test "returns '/' for root with default locale when path_only" do
    assert_equal "/?_lr=1", @helper.url_for_locale("en", "/", path_only: true)
  end

  test "returns host only for root with default locale" do
    @request.stubs base_url: "https://exercism.org"
    assert_equal "https://exercism.org?_lr=1", @helper.url_for_locale("en", "/", path_only: false)
  end

  test "prefixes locale for root when non-default" do
    @request.stubs base_url: "https://exercism.org"
    assert_equal "/fr?_lr=1", @helper.url_for_locale("fr", "/", path_only: true)
    assert_equal "https://exercism.org/fr?_lr=1", @helper.url_for_locale("fr", "/")
  end

  test "strips trailing slashes from paths" do
    assert_equal "/foo?_lr=1", @helper.url_for_locale("en", "/foo/", path_only: true)
    assert_equal "/fr/foo/bar?_lr=1", @helper.url_for_locale("fr", "/foo/bar/", path_only: true)
  end

  test "drops existing locale segment" do
    assert_equal "/fr/foo?_lr=1", @helper.url_for_locale("fr", "/en/foo", path_only: true)
  end

  test "preserves query params" do
    url = @helper.url_for_locale("fr", "/foo/bar?a=1&b=2", path_only: true)
    assert_match %r{^/fr/foo/bar\?(.*a=1.*&.*b=2.*|.*b=2.*&.*a=1.*)}, url
  end

  test "adds loop-breaker query param if missing" do
    url = @helper.url_for_locale("fr", "/foo", path_only: true)
    assert_equal "/fr/foo?#{LocaleSupport::QUERY_PARAM}=1", url
  end

  test "does not duplicate loop-breaker if already present" do
    qp = LocaleSupport::QUERY_PARAM
    url = @helper.url_for_locale("fr", "/foo?#{qp}=1", path_only: true)
    assert_equal "/fr/foo?#{qp}=1", url
  end
end
