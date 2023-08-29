require "test_helper"

class User::AuthenticateFromOmniauthTest < ActiveSupport::TestCase
  test "bootstraps a new user" do
    auth = stub(
      provider: "github",
      uid: "111",
      info: stub(
        email: "user@exercism.org",
        name: "Name",
        nickname: "user22",
        image: "http://some.image/avatar.jpg"
      )
    )

    User::Bootstrap.expects(:call).with do |user|
      assert user.is_a?(User)
    end
    User::AuthenticateFromOmniauth.(auth)
  end

  test "creates new user using auth info" do
    auth = stub(
      provider: "github",
      uid: "111",
      info: stub(
        email: "user@exercism.org",
        name: "Name",
        nickname: "user22",
        image: "http://some.image/avatar.jpg"
      )
    )

    User::AuthenticateFromOmniauth.(auth)

    user = User.find_by(uid: "111")
    assert_equal "github", user.provider
    assert_equal "111", user.uid
    assert_equal "user@exercism.org", user.email
    assert_equal "Name", user.name
    assert_equal "user22", user.github_username
    assert_equal "http://some.image/avatar.jpg", user.attributes["avatar_url"]
  end

  test "copes with duplicate gh username but unauthed" do
    nickname = "user22"
    create :user, github_username: nickname
    auth = stub(
      provider: "github",
      uid: "111",
      info: stub(
        email: "user@exercism.org",
        name: "Name",
        nickname:,
        image: "http://some.image/avatar.jpg"
      )
    )

    user = User::AuthenticateFromOmniauth.(auth)
    assert_nil user.reload.github_username
  end

  test "updates email and github_username if from users.noreply.github.com" do
    user = create :user, provider: "github", uid: "111", email: "user@users.noreply.github.com", avatar_url: "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=xxx"
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.org", nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert_equal "user@exercism.org", user.email
    assert_equal "user22", user.github_username
  end

  test "updates avatar if missing" do
    user = create :user, provider: "github", uid: "111", avatar_url: nil, avatar: nil
    auth = stub(provider: "github", uid: "111", info: stub(image: "http://some.image/avatar.jpg", nickname: "foobar"))

    User::AuthenticateFromOmniauth.(auth)

    assert_equal "http://some.image/avatar.jpg", user.reload.attributes['avatar_url']
  end

  test "does not update avatar if present" do
    user = create :user, provider: "github", uid: "111", avatar_url: "original.jpg", avatar: nil
    auth = stub(provider: "github", uid: "111", info: stub(nickname: "foobar"))

    User::AuthenticateFromOmniauth.(auth)

    assert_equal "original.jpg", user.reload.attributes["avatar_url"]
  end

  test "sets provider, uid and github_username for email matches" do
    user = create :user, email: "user@exercism.org"
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.org", nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert_equal "111", user.uid
    assert_equal "github", user.provider
    assert_equal "user22", user.github_username
  end

  test "confirms user and changes password if email matches" do
    SecureRandom.stubs(:uuid).returns("12345678")
    user = create :user, email: "user@exercism.org", confirmed_at: nil
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.org", nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    assert user.confirmed?
    assert user.valid_password?("12345678")
  end

  test "does not change password if user confirmed" do
    user = create :user, email: "user@exercism.org", github_username: "user22", confirmed_at: Date.new(2016, 12, 25)
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.org", nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    user.reload
    refute user.valid_password?("12345678")
  end

  test "ensures handle uniqueness" do
    create :user, handle: "user22"
    auth = stub(
      provider: "github",
      uid: "111",
      info: stub(
        email: "user@exercism.org",
        name: "Name",
        nickname: "user22",
        image: "http://some.image/avatar.jpg"
      )
    )

    user = User::AuthenticateFromOmniauth.(auth)

    assert user.persisted?
    refute_equal "user22", user.handle
  end

  test "recalculate pull request reputation for uid matches that change the github_username" do
    user = create :user, provider: "github", uid: "111", github_username: nil, avatar_url: "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=xxx"
    auth = stub(provider: "github", uid: "111", info: stub(nickname: "user22"))

    assert_enqueued_with(job: MandateJob, args: [User::ReputationToken::AwardForPullRequestsForUser.name, user],
      queue: 'reputation') do
      User::AuthenticateFromOmniauth.(auth)
    end
  end

  test "don't recalculate pull request reputation for uid matches that don't change the github_username" do
    create :user, provider: "github", uid: "111", github_username: "user22", avatar_url: "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=xxx"
    auth = stub(provider: "github", uid: "111", info: stub(nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    assert_no_enqueued_jobs(only: MandateJob)
  end

  test "recalculate pull request reputation for email matches that change the github_username" do
    user = create :user, email: "user@exercism.org", github_username: nil
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.org", nickname: "user22"))

    assert_enqueued_with(job: MandateJob, args: [User::ReputationToken::AwardForPullRequestsForUser.name, user],
      queue: 'reputation') do
      User::AuthenticateFromOmniauth.(auth)
    end
  end

  test "don't recalculate pull request reputation for email matches that don't change the github_username" do
    create :user, email: "user@exercism.org", github_username: "user22"
    auth = stub(provider: "github", uid: "111", info: stub(email: "user@exercism.org", nickname: "user22"))

    User::AuthenticateFromOmniauth.(auth)

    assert_no_enqueued_jobs(only: MandateJob)
  end

  test "calculate pull request reputation for bootstrapped user" do
    auth = stub(
      provider: "github",
      uid: "111",
      info: stub(
        email: "user@exercism.org",
        name: "Name",
        nickname: "user22",
        image: "http://some.image/avatar.jpg"
      )
    )

    assert_enqueued_with(job: MandateJob, args: lambda { |job_args|
                                                  job_args[0] == User::ReputationToken::AwardForPullRequestsForUser.name
                                                }, queue: 'reputation') do
      User::AuthenticateFromOmniauth.(auth)
    end
  end
end
