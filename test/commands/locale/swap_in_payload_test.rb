require 'test_helper'

class Locale::SwapInPayloadTest < ActiveSupport::TestCase
  test "the default locale is left exactly as it is" do
    payload = { links: { self: url("/tracks/ruby") } }

    assert_same payload, Locale::SwapInPayload.(payload, :en)
  end

  test "locale-scoped urls gain the prefix" do
    with_available_locales(:hu) do
      assert_equal(
        { links: { self: url("/hu/tracks/ruby/exercises/bob/iterations?idx=0") } },
        Locale::SwapInPayload.({ links: { self: url("/tracks/ruby/exercises/bob/iterations?idx=0") } }, :hu)
      )
    end
  end

  test "api urls are left alone" do
    api_url = url("/api/v2/solutions/abc/iterations/def/automated_feedback")

    with_available_locales(:hu) do
      assert_equal({ links: { delete: api_url } }, Locale::SwapInPayload.({ links: { delete: api_url } }, :hu))
    end
  end

  test "english-only website urls are left alone" do
    challenge_url = url("/challenges/12in23")

    with_available_locales(:hu) do
      assert_equal({ link: challenge_url }, Locale::SwapInPayload.({ link: challenge_url }, :hu))
    end
  end

  test "urls on other hosts, unrecognised paths and plain values are left alone" do
    payload = {
      avatar: "https://assets.example.org/avatars/1.jpg",
      unknown: url("/nothing/here/at/all"),
      language: "ruby",
      indent_size: 2,
      out_of_date: false,
      published_iteration_idx: nil
    }

    with_available_locales(:hu) do
      assert_equal payload, Locale::SwapInPayload.(payload, :hu)
    end
  end

  test "urls nested in arrays are reached" do
    with_available_locales(:hu) do
      assert_equal(
        { iterations: [{ links: { solution: url("/hu/tracks/ruby/exercises/bob") } }] },
        Locale::SwapInPayload.({ iterations: [{ links: { solution: url("/tracks/ruby/exercises/bob") } }] }, :hu)
      )
    end
  end

  private
  def url(path) = "#{Exercism::Routes.host.delete_suffix('/')}#{path}"
end
