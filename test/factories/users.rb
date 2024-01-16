FactoryBot.define do
  factory :user do
    email { "#{SecureRandom.hex(4)}@exercism.org" }
    name { "User" }
    password { "password" }
    handle { "handle-#{SecureRandom.hex(4)}" }
    accepted_terms_at { Date.new(2016, 12, 25) }
    accepted_privacy_policy_at { Date.new(2016, 12, 25) }
    became_mentor_at { Date.new(2016, 12, 25) }
    avatar do
      # Ensure we have a file with a different filename each time
      tempfile = Tempfile.new([SecureRandom.uuid, '.png'])
      tempfile.write(File.read(Rails.root.join("app", "images", "favicon.png")))
      tempfile.rewind

      Rack::Test::UploadedFile.new(tempfile.path, 'image/png')
    end

    after(:build) do |user|
      user.data.email_status = :verified
    end

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

    trait :external_avatar_url do
      after(:create) do |user, _evaluator|
        user.avatar.delete
        user.update(avatar_url: "https://avatars.githubusercontent.com/u/5624255?s=200&v=4&e_uid=#{user.id}")
        user.reload
      end
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

    %i[founder admin staff maintainer].each do |role|
      trait role do
        after(:create) do |user, _evaluator|
          user.data.update!(
            roles: (user.data.roles + [role])
          )
        end
      end
    end

    trait :supermentor do
      after(:create) do |user, _evaluator|
        data = user.data
        data.update!(
          roles: (data.roles + [:supermentor]),
          cache: (data.cache || {}).merge({ 'mentor_satisfaction_percentage' => 98 })
        )
      end
    end

    trait :insider do
      insiders_status { :active }
    end

    trait :lifetime_insider do
      insiders_status { :active_lifetime }
    end

    trait :github do
      after(:create) do |user, _evaluator|
        user.data.update(github_username: user.handle)
      end
    end

    trait :trainer do
      after(:create) do |user, _evaluator|
        user.data.update(trainer: true)
      end
    end
  end
end
