FactoryBot.define do
  factory :blog_post do
    author { create :user }
    uuid { SecureRandom.uuid }
    slug { "sorry-for-the-wait" }
    category { :updates }
    published_at { Time.current - 1.minute }

    title { "Some blog post" }
    marketing_copy { "Have a read of this" }

    trait :random_slug do
      slug { "slug-#{SecureRandom.uuid}" }
    end
  end
end
