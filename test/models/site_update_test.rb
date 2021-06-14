require 'test_helper'

class SiteUpdateTest < ActiveSupport::TestCase
  test "text is sanitized" do
    update = SiteUpdates::NewExerciseUpdate.new
    update.define_singleton_method(:i18n_params) do
      { user: "<foo>d</foo>angerous" }
    end

    I18n.expects(:t).with(
      "site_updates.new_exercise.",
      { user: "dangerous" }
    ).returns("")

    update.text
  end

  test "rendering_data with no contributors" do
    freeze_time do
      track = create :track
      exercise = create :concept_exercise, track: track
      update = create :site_update, exercise: exercise, track: track

      expected = {
        text: "<em>We</em> published a new exercise: #{i18n_exercise(exercise)}",
        icon_url: exercise.icon_url,
        published_at: (Time.current + 3.hours).iso8601,
        maker_avatar_urls: []
      }.with_indifferent_access

      assert_equal expected, update.rendering_data
    end
  end

  test "rendering_data with 1 contributors" do
    track = create :track
    author = create :user
    exercise = create :concept_exercise, track: track
    create :exercise_authorship, exercise: exercise, author: author
    update = create :site_update, exercise: exercise, track: track

    text = "<em>#{author.handle}</em> published a new exercise: #{i18n_exercise(exercise)}"
    assert_equal text, update.rendering_data[:text]
    assert_equal [author.avatar_url], update.rendering_data[:maker_avatar_urls]
  end

  test "rendering_data with 2 contributors" do
    track = create :track
    contributor = create :user
    author = create :user
    exercise = create :concept_exercise, track: track
    create :exercise_contributorship, exercise: exercise, contributor: contributor
    create :exercise_authorship, exercise: exercise, author: author
    update = create :site_update, exercise: exercise, track: track

    text = "<em>#{author.handle} and #{contributor.handle}</em> published a new exercise: #{i18n_exercise(exercise)}"
    assert_equal text, update.rendering_data[:text]
    assert_equal [author, contributor].map(&:avatar_url), update.rendering_data[:maker_avatar_urls]
  end

  test "rendering_data with 3 contributors" do
    track = create :track
    contributor_1 = create :user
    author = create :user
    contributor_2 = create :user
    exercise = create :concept_exercise, track: track
    create :exercise_contributorship, exercise: exercise, contributor: contributor_1
    create :exercise_authorship, exercise: exercise, author: author
    create :exercise_contributorship, exercise: exercise, contributor: contributor_2
    update = create :site_update, exercise: exercise, track: track

    text = "<em>#{author.handle}, #{contributor_1.handle}, and #{contributor_2.handle}</em> published a new exercise: #{i18n_exercise(exercise)}" # rubocop:disable Layout/LineLength
    assert_equal text, update.rendering_data[:text]
    assert_equal [author, contributor_1, contributor_2].map(&:avatar_url), update.rendering_data[:maker_avatar_urls]
  end

  test "rendering_data with 4 contributors" do
    track = create :track
    contributor_1 = create :user
    author = create :user
    contributor_2 = create :user
    contributor_3 = create :user
    exercise = create :concept_exercise, track: track
    create :exercise_contributorship, exercise: exercise, contributor: contributor_1
    create :exercise_authorship, exercise: exercise, author: author
    create :exercise_contributorship, exercise: exercise, contributor: contributor_2
    create :exercise_contributorship, exercise: exercise, contributor: contributor_3
    update = create :site_update, exercise: exercise, track: track

    text = "<em>#{author.handle}, #{contributor_1.handle}, and 2 others</em> published a new exercise: #{i18n_exercise(exercise)}" # rubocop:disable Layout/LineLength
    assert_equal text, update.rendering_data[:text]
    assert_equal [author, contributor_1, contributor_2, contributor_3].map(&:avatar_url),
      update.rendering_data[:maker_avatar_urls]
  end

  test "rendering expanded data" do
    track = create :track
    exercise = create :concept_exercise, track: track

    author = create :user
    title = "Check this out!!"
    description = "I did something really cool :)"
    update = create :site_update, exercise: exercise, track: track, author: author, title: title, description: description

    expected = {
      author_handle: author.handle,
      author_avatar_url: author.avatar_url,
      title: title,
      description: description
    }.stringify_keys
    assert_equal expected, update.rendering_data[:expanded]
  end

  test "rendering pull request" do
    track = create :track
    exercise = create :concept_exercise, track: track

    pull_request = create :github_pull_request
    update = create :site_update, exercise: exercise, track: track, pull_request: pull_request

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

  def i18n_exercise(exercise)
    %(<a href="#{Exercism::Routes.track_exercise_url(exercise.track, exercise)}">#{exercise.title}</a>)
  end
end
