FactoryBot.define do
  factory :course_enrollment do
    name { "Foo Bar" }
    email { "foo#{SecureRandom.hex(4)}@bar.com" }
    course_slug { "coding-fundamentals" }
  end

  trait :coding_fundamentals do
    course_slug { "coding-fundamentals" }
  end

  trait :front_end_fundamentals do
    course_slug { "front-end-fundamentals" }
  end

  trait :bundle_coding_front_end do
    course_slug { "bundle-coding-front-end" }
  end

  trait :paid do
    paid_at { Time.current }
    checkout_session_id { SecureRandom.hex(8) }
    access_code { SecureRandom.hex(8) }
  end

  trait :india do
    country_code_2 { "IN" }
  end
end
