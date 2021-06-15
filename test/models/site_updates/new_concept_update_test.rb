require 'test_helper'

class SiteUpdates::NewConceptUpdateTest < ActiveSupport::TestCase
  test "rendering_data with no contributors" do
    freeze_time do
      track = create :track
      concept = create :concept, track: track
      update = create :new_concept_site_update, track: track, params: { concept: concept }

      expected = {
        text: "<em>We</em> published a new Concept: #{i18n_concept(concept)}",
        icon_type: 'concept',
        icon_url: "Co",
        track_icon_url: track.icon_url,
        published_at: (Time.current + 3.hours).iso8601,
        maker_avatar_urls: []
      }.with_indifferent_access

      assert_equal expected, update.rendering_data
    end
  end

  test "rendering_data with 1 contributors" do
    # TODO: Readd once we have contributors
    skip
    track = create :track
    author = create :user
    concept = create :concept, track: track
    create :concept_authorship, concept: concept, author: author
    update = create :new_concept_site_update, track: track, params: { concept: concept }

    text = "<em>#{author.handle}</em> published a new Concept: #{i18n_concept(concept)}"
    assert_equal text, update.rendering_data[:text]
    assert_equal [author.avatar_url], update.rendering_data[:maker_avatar_urls]
  end

  test "rendering_data with 2 contributors" do
    # TODO: Readd once we have contributors
    skip
    track = create :track
    contributor = create :user
    author = create :user
    concept = create :concept, track: track
    create :concept_contributorship, concept: concept, contributor: contributor
    create :concept_authorship, concept: concept, author: author
    update = create :new_concept_site_update, track: track, params: { concept: concept }

    text = "<em>#{author.handle} and #{contributor.handle}</em> published a new Concept: #{i18n_concept(concept)}"
    assert_equal text, update.rendering_data[:text]
    assert_equal [author, contributor].map(&:avatar_url), update.rendering_data[:maker_avatar_urls]
  end

  test "rendering_data with 3 contributors" do
    # TODO: Readd once we have contributors
    skip
    track = create :track
    contributor_1 = create :user
    author = create :user
    contributor_2 = create :user
    concept = create :concept, track: track
    create :concept_contributorship, concept: concept, contributor: contributor_1
    create :concept_authorship, concept: concept, author: author
    create :concept_contributorship, concept: concept, contributor: contributor_2
    update = create :new_concept_site_update, track: track, params: { concept: concept }

    text = "<em>#{author.handle}, #{contributor_1.handle}, and #{contributor_2.handle}</em> published a new Concept: #{i18n_concept(concept)}" # rubocop:disable Layout/LineLength
    assert_equal text, update.rendering_data[:text]
    assert_equal [author, contributor_1, contributor_2].map(&:avatar_url), update.rendering_data[:maker_avatar_urls]
  end

  test "rendering_data with 4 contributors" do
    # TODO: Readd once we have contributors
    skip
    track = create :track
    contributor_1 = create :user
    author = create :user
    contributor_2 = create :user
    contributor_3 = create :user
    concept = create :concept, track: track
    create :concept_contributorship, concept: concept, contributor: contributor_1
    create :concept_authorship, concept: concept, author: author
    create :concept_contributorship, concept: concept, contributor: contributor_2
    create :concept_contributorship, concept: concept, contributor: contributor_3
    update = create :new_concept_site_update, track: track, params: { concept: concept }

    text = "<em>#{author.handle}, #{contributor_1.handle}, and 2 others</em> published a new Concept: #{i18n_concept(concept)}" # rubocop:disable Layout/LineLength
    assert_equal text, update.rendering_data[:text]
    assert_equal [author, contributor_1, contributor_2, contributor_3].map(&:avatar_url),
      update.rendering_data[:maker_avatar_urls]
  end

  def i18n_concept(concept)
    %(<a href="#{Exercism::Routes.track_concept_url(concept.track, concept)}">#{concept.name}</a>)
  end
end
