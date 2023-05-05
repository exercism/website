require 'test_helper'

class SiteUpdateTest < ActiveSupport::TestCase
  test "text is sanitized" do
    update = SiteUpdates::NewExerciseUpdate.new
    update.define_singleton_method(:i18n_params) do
      { user: "<foo>d</foo>angerous" }
    end

    I18n.expects(:t).with(
      "site_updates.new_exercise.",
      user: "dangerous"
    ).returns("")

    update.text
  end

  test "rendering expanded data" do
    track = create :track
    exercise = create(:concept_exercise, track:)

    author = create :user
    title = "Check this out!!"
    description_markdown = "I did something really cool :)"
    description_html = "<p>I did something really cool :)</p>\n"
    update = create(:site_update, exercise:, track:, author:, title:,
      description_markdown:)

    expected = {
      author: {
        "handle" => author.handle,
        "avatar_url" => author.avatar_url
      },
      title:,
      description_html:
    }.stringify_keys
    assert_equal expected, update.rendering_data[:expanded]
  end

  test "rendering pull request" do
    track = create :track
    exercise = create(:concept_exercise, track:)

    pull_request = create :github_pull_request
    update = create(:site_update, exercise:, track:, pull_request:)

    expected = {
      title: pull_request.title,
      number: pull_request.number,
      url: "https://github.com/#{pull_request.repo}/pull/#{pull_request.number}",
      merged_by: pull_request.merged_by_username,
      merged_at: pull_request.updated_at.iso8601
    }.stringify_keys
    assert_equal expected, update.rendering_data[:pull_request]
  end

  test "published_at is set to now + 3.hours" do
    freeze_time do
      update = create :site_update
      assert_equal Time.current + 3.hours, update.published_at
    end
  end

  test "published scope" do
    published = create :site_update, published_at: Time.current - 1.minute
    unpublished = create :site_update, published_at: Time.current + 1.minute

    assert_equal [published, unpublished], SiteUpdate.all # Sanity
    assert_equal [published], SiteUpdate.published
  end

  test "sorted scope" do
    first = create :site_update, published_at: Time.current - 1.minute
    third = create :site_update, published_at: Time.current + 2.minutes
    second = create :site_update, published_at: Time.current

    assert_equal [third, second, first], SiteUpdate.sorted
  end

  test "for track scope" do
    ruby = create :track, slug: 'ruby'
    js = create :track, slug: 'js'
    ruby_update = create :site_update, track: ruby
    js_update = create :site_update, track: js

    assert_equal [ruby_update, js_update], SiteUpdate.all # Sanity
    assert_equal [js_update], SiteUpdate.for_track(js)
  end

  test "updates description_html when description_markdown is set" do
    site_update = create :site_update, description_markdown: nil
    assert_nil site_update.description_html

    site_update.update(description_markdown: "Hi there")
    assert_equal "<p>Hi there</p>\n", site_update.description_html
  end
end
