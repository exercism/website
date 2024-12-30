FactoryBot.define do
  factory :bootcamp_user_project, class: "Bootcamp::UserProject" do
    user { create(:user, :with_bootcamp_data) }
    project { create(:bootcamp_project) }
  end
end
