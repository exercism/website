require "test_helper"

class User::ReputationToken::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    user = create :user
    token = create :user_reputation_token, user: user

    # Someone else's token
    create :user_reputation_token

    assert_equal [token], User::ReputationToken::Search.(user)
  end

  test "criteria" do
    user = create :user
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "JavaScript", slug: "javascript"
    bob = create :concept_exercise, title: "Bob"
    food = create :concept_exercise, title: "Food Chain"

    ruby_bob_token = create :user_reputation_token, user: user, exercise: bob, track: ruby
    ruby_food_token = create :user_reputation_token, user: user, exercise: food, track: ruby
    js_bob_token = create :user_reputation_token, user: user, exercise: bob, track: javascript

    assert_equal [ruby_bob_token, ruby_food_token, js_bob_token], User::ReputationToken::Search.(user)
    assert_equal [ruby_bob_token, ruby_food_token, js_bob_token], User::ReputationToken::Search.(user, criteria: " ")
    assert_equal [ruby_bob_token, ruby_food_token], User::ReputationToken::Search.(user, criteria: "ru")
    assert_equal [ruby_bob_token, js_bob_token], User::ReputationToken::Search.(user, criteria: "bo")
    assert_equal [ruby_bob_token], User::ReputationToken::Search.(user, criteria: "r bo")
  end

  test "status" do
    user = create :user
    building = create :user_reputation_token, user: user, category: :building
    authoring = create :user_reputation_token, user: user, category: :authoring
    mentoring = create :user_reputation_token, user: user, category: :mentoring

    assert_equal [building, authoring, mentoring], User::ReputationToken::Search.(user, category: ' ')
    assert_equal [building], User::ReputationToken::Search.(user, category: :building)
    assert_equal [building], User::ReputationToken::Search.(user, category: 'building')
    assert_equal [authoring], User::ReputationToken::Search.(user, category: :authoring)
    assert_equal [authoring], User::ReputationToken::Search.(user, category: 'authoring')
    assert_equal [mentoring], User::ReputationToken::Search.(user, category: :mentoring)
    assert_equal [mentoring], User::ReputationToken::Search.(user, category: 'mentoring')
  end
end
