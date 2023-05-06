FactoryBot.define do
  factory :user do
    email { "#{SecureRandom.hex(4)}@exercism.org" }
    name { "User" }
    password { "password" }
    handle { "handle-#{SecureRandom.hex(4)}" }
    avatar_url { "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=xxx" }

    after(:create) do |user, _evaluator|
      # Update the avatar if we've had a placeholder in the factory
      if user.avatar_url.ends_with?("e_uid=xxx")
        user.update(
          avatar_url: "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=#{user.id}"
        )
      end

      user.reload.data.update!(
        accepted_terms_at: Date.new(2016, 12, 25),
        accepted_privacy_policy_at: Date.new(2016, 12, 25),
        became_mentor_at: Date.new(2016, 12, 25)
      )
    end

    trait :donor do
      after(:create) do |user, _evaluator|
        user.data.update(first_donated_at: Time.current)
      end
    end

    trait :not_mentor do
      after(:create) do |user, _evaluator|
        user.data.update(became_mentor_at: nil)
      end
    end

    trait :not_onboarded do
      after(:create) do |user, _evaluator|
        user.data.update(
          accepted_terms_at: nil,
          accepted_privacy_policy_at: nil
        )
      end
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

    %i[founder admin staff maintainer supermentor].each do |role|
      trait role do
        after(:create) do |user, _evaluator|
          user.data.update(roles: [role])
        end
      end
    end

    trait :insider do
      active_donation_subscription { true }
      insiders_status { :active }
    end

    trait :github do
      after(:create) do |user, _evaluator|
        user.data.update(github_username: user.handle)
      end
    end
  end
end
