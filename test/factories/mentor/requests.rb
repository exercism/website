FactoryBot.define do
  factory :mentor_request, class: 'Mentor::Request' do
    solution { create :practice_solution }
    comment_markdown { "I could do with some help here" }
    external { false }

    trait :pending do
      status { :pending }
    end

    trait :fulfilled do
      status { :fulfilled }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :external do
      external { true }
    end

    trait :v2 do
      to_create do |request|
        request.v2 = true
        request.save!
      end
    end
  end
end
