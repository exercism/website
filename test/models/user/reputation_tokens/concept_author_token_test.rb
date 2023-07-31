require "test_helper"

class User::ReputationTokens::ConceptAuthorTokenTest < ActiveSupport::TestCase
  test "creates authorship reputation token" do
    user = create :user, handle: "User22", github_username: "user22"
    authorship = create :concept_authorship, author: user
    concept = authorship.concept
    track = concept.track

    User::ReputationToken::Create.(
      user,
      :concept_author,
      authorship:
    )

    assert_equal 1, user.reputation_tokens.size
    rt = user.reputation_tokens.first

    assert_instance_of User::ReputationTokens::ConceptAuthorToken, rt
    assert_equal "You authored <strong>#{concept.name}</strong>", rt.text
    assert_equal concept, rt.concept
    assert_equal track, rt.track
    assert_equal "#{user.id}|concept_author|Concept##{concept.id}", rt.uniqueness_key
    assert_equal :authored_concept, rt.reason
    assert_equal :authoring, rt.category
    assert_equal 10, rt.value
    assert_equal concept.created_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.track_concept_path(track, concept), rt.rendering_data[:internal_url]
  end
end
