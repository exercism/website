FactoryBot.define do
  factory :bootcamp_user_project, class: "Bootcamp::UserProject" do
    user
    project { create(:bootcamp_project) }
  end
end
