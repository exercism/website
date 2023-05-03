require 'test_helper'

class SiteUpdates::NewExerciseUpdateTest < ActiveSupport::TestCase
  test "rendering_data with no contributors" do
    freeze_time do
      track = create :track
      exercise = create(:concept_exercise, track:)
      update = create(:new_exercise_site_update, exercise:, track:)

      expected = {
        text: "<em>We</em> published a new Exercise: #{i18n_exercise(exercise)}",
        icon: {
          type: 'image',
          url: exercise.icon_url
        },
        track: {
          title: track.title,
          icon_url: track.icon_url
        },
        published_at: (Time.current + 3.hours).iso8601,
        makers: []
      }.with_indifferent_access

      assert_equal expected, update.rendering_data
    end
  end

  test "rendering_data with 1 contributors" do
    track = create :track
    author = create :user
    exercise = create(:concept_exercise, track:)
    create(:exercise_authorship, exercise:, author:)
    update = create(:new_exercise_site_update, exercise:, track:)

    text = "<em>#{author.handle}</em> published a new Exercise: #{i18n_exercise(exercise)}"
    assert_equal text, update.rendering_data[:text]
    assert_equal(
      [author].map do |maker|
        {
          handle: maker.handle,
          avatar_url: maker.avatar_url,
          flair: maker.flair
        }.stringify_keys
      end,
      update.rendering_data[:makers]
    )
  end

  test "rendering_data with 2 contributors" do
    track = create :track
    contributor = create :user
    author = create :user
    exercise = create(:concept_exercise, track:)
    create(:exercise_contributorship, exercise:, contributor:)
    create(:exercise_authorship, exercise:, author:)
    update = create(:new_exercise_site_update, exercise:, track:)

    text = "<em>#{author.handle} and #{contributor.handle}</em> published a new Exercise: #{i18n_exercise(exercise)}"
    assert_equal text, update.rendering_data[:text]
    assert_equal(
      [author, contributor].map do |maker|
        {
          handle: maker.handle,
          avatar_url: maker.avatar_url,
          flair: maker.flair
        }.stringify_keys
      end,
      update.rendering_data[:makers]
    )
  end

  test "rendering_data with 3 contributors" do
    track = create :track
    contributor_1 = create :user
    author = create :user
    contributor_2 = create :user
    exercise = create(:concept_exercise, track:)
    create :exercise_contributorship, exercise:, contributor: contributor_1
    create(:exercise_authorship, exercise:, author:)
    create :exercise_contributorship, exercise:, contributor: contributor_2
    update = create(:new_exercise_site_update, exercise:, track:)

    text = "<em>#{author.handle}, #{contributor_1.handle}, and #{contributor_2.handle}</em> published a new Exercise: #{i18n_exercise(exercise)}" # rubocop:disable Layout/LineLength
    assert_equal text, update.rendering_data[:text]
    assert_equal(
      [author, contributor_1, contributor_2].map do |maker|
        {
          handle: maker.handle,
          avatar_url: maker.avatar_url,
          flair: maker.flair
        }.stringify_keys
      end,
      update.rendering_data[:makers]
    )
  end

  test "rendering_data with 4 contributors" do
    track = create :track
    contributor_1 = create :user
    author = create :user
    contributor_2 = create :user
    contributor_3 = create :user
    exercise = create(:concept_exercise, track:)
    create :exercise_contributorship, exercise:, contributor: contributor_1
    create(:exercise_authorship, exercise:, author:)
    create :exercise_contributorship, exercise:, contributor: contributor_2
    create :exercise_contributorship, exercise:, contributor: contributor_3
    update = create(:new_exercise_site_update, exercise:, track:)

    text = "<em>#{author.handle}, #{contributor_1.handle}, and 2 others</em> published a new Exercise: #{i18n_exercise(exercise)}"
    assert_equal text, update.rendering_data[:text]
    assert_equal(
      [author, contributor_1, contributor_2, contributor_3].map do |maker|
        {
          handle: maker.handle,
          avatar_url: maker.avatar_url,
          flair: maker.flair
        }.stringify_keys
      end,
      update.rendering_data[:makers]
    )
  end

  def i18n_exercise(exercise)
    %(<a href="#{Exercism::Routes.track_exercise_url(exercise.track, exercise)}">#{exercise.title}</a>)
  end
end
