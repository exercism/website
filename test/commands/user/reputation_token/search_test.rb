require "test_helper"

class User::ReputationToken::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    user = create :user
    token = create(:user_code_contribution_reputation_token, user:)

    # Someone else's token
    create :user_code_contribution_reputation_token

    assert_equal [token], User::ReputationToken::Search.(user)
  end

  test "criteria" do
    user = create :user
    javascript = create :track, title: "JavaScript", slug: "javascript"
    ruby = create :track, title: "Ruby"
    food = create :concept_exercise, title: "Food Chain"
    bob = create :concept_exercise, title: "Bob"

    js_bob_token = create :user_code_contribution_reputation_token, user:, exercise: bob, track: javascript
    ruby_food_token = create :user_code_contribution_reputation_token, user:, exercise: food, track: ruby
    ruby_bob_token = create :user_code_contribution_reputation_token, user:, exercise: bob, track: ruby

    assert_equal [ruby_bob_token, ruby_food_token, js_bob_token], User::ReputationToken::Search.(user)
    assert_equal [ruby_bob_token, ruby_food_token, js_bob_token], User::ReputationToken::Search.(user, criteria: " ")
    assert_equal [ruby_bob_token, ruby_food_token], User::ReputationToken::Search.(user, criteria: "ru")
    assert_equal [ruby_bob_token, js_bob_token], User::ReputationToken::Search.(user, criteria: "bo")
    assert_equal [ruby_bob_token], User::ReputationToken::Search.(user, criteria: "r bo")
  end

  # TODO: Readd mentoring to this
  test "status" do
    user = create :user
    # mentoring = create :user_reputation_token, user: user, category: :mentoring
    authoring = create :user_exercise_author_reputation_token, user:, category: :authoring
    building = create :user_code_contribution_reputation_token, user:, category: :building

    # assert_equal [building, authoring, mentoring], User::ReputationToken::Search.(user, category: ' ')
    assert_equal [building], User::ReputationToken::Search.(user, category: :building)
    assert_equal [building], User::ReputationToken::Search.(user, category: 'building')
    assert_equal [authoring], User::ReputationToken::Search.(user, category: :authoring)
    assert_equal [authoring], User::ReputationToken::Search.(user, category: 'authoring')
    # assert_equal [mentoring], User::ReputationToken::Search.(user, category: :mentoring)
    # assert_equal [mentoring], User::ReputationToken::Search.(user, category: 'mentoring')
  end

  test "sort oldest first" do
    user = create :user
    token_1 = create(:user_code_contribution_reputation_token, user:)
    token_2 = create(:user_code_contribution_reputation_token, user:)

    assert_equal [token_1, token_2], User::ReputationToken::Search.(user, order: "oldest_first")
  end

  test "sort newest first by default" do
    user = create :user
    token_1 = create(:user_code_contribution_reputation_token, user:)
    token_2 = create(:user_code_contribution_reputation_token, user:)

    assert_equal [token_2, token_1], User::ReputationToken::Search.(user)
  end

  test "sort by unseen first" do
    user = create :user
    token_1 = create :user_code_contribution_reputation_token, user:, seen: true
    token_2 = create :user_code_contribution_reputation_token, user:, seen: false
    token_3 = create :user_code_contribution_reputation_token, user:, seen: true

    assert_equal [token_2, token_3, token_1], User::ReputationToken::Search.(user, order: :unseen_first)
  end

  test "returns relationship unless paginated" do
    user = create :user
    create(:user_code_contribution_reputation_token, user:)

    tokens = User::ReputationToken::Search.(user, paginated: false)
    assert tokens.is_a?(ActiveRecord::Relation)
    refute_respond_to tokens, :current_page
  end
end
