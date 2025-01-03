FactoryBot.define do
  factory :bootcamp_submission, class: "Bootcamp::Submission" do
    solution { create(:bootcamp_solution) }
    code { "Some code" }
    test_results do
      {
        status: :pass,
        tests: []
      }
    end
    readonly_ranges do
      []
    end
  end
end
