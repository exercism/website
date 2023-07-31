require "test_helper"

class Exercise::Article::Authorship::CreateTest < ActiveSupport::TestCase
  test "awards reputation" do
    user = create :user
    article = create :exercise_article

    perform_enqueued_jobs do
      Exercise::Article::Authorship::Create.(article, user)
    end

    assert_equal 1, User::ReputationTokens::ExerciseArticleAuthorToken.where(user:).count
  end

  test "idempotent" do
    user = create :user
    article = create :exercise_article

    assert_idempotent_command do
      Exercise::Article::Authorship::Create.(article, user)
    end

    assert_equal 1, Exercise::Article::Authorship.count
  end
end
