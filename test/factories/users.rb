FactoryBot.define do
  factory :user do
    email { "#{SecureRandom.hex(4)}@exercism.org" }
    name { "User" }
    password { "password" }
    handle { "handle-#{SecureRandom.hex(4)}" }
    accepted_terms_at { Date.new(2016, 12, 25) }
    accepted_privacy_policy_at { Date.new(2016, 12, 25) }
    became_mentor_at { Date.new(2016, 12, 25) }
    avatar_url { "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=xxx" }

    after(:create) do |user, _evaluator|
      # Update the avatar if we've had a placeholder in the factory
      if user.avatar_url.ends_with?("e_uid=xxx")
        user.update(
          avatar_url: "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=#{user.id}"
        )
      end
    end

    trait :donor do
      first_donated_at { Time.current }
    end

    trait :not_mentor do
      became_mentor_at { nil }
    end

    trait :not_onboarded do
      accepted_terms_at { nil }
      accepted_privacy_policy_at { nil }
    end

    trait :system do
      id { User::SYSTEM_USER_ID }
      github_username { 'exercism-bot' }
    end

    trait :ghost do
      id { User::GHOST_USER_ID }
      github_username { 'exercism-ghost' }
      name { "Ghost" }
    end

    trait :admin do
      roles { [:admin] }
    end

    trait :staff do
      roles { [:staff] }
    end

    trait :maintainer do
      roles { [:maintainer] }
    end

    trait :supermentor do
      roles { [:supermentor] }
    end

    trait :staff do
      roles { [:staff] }
    end

    trait :github do
      github_username { handle }
    end
  end
end
