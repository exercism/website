class Bootcamp::UserProject::Create
  include Mandate

  initialize_with :user, :project

  def call
    create_or_find.tap do |up|
      Bootcamp::UserProject::UpdateStatus.(up)
    end
  end

  def create_or_find
    Bootcamp::UserProject.create!(user:, project:)
  rescue StandardError
    Bootcamp::UserProject.find_by!(user:, project:)
  end
end
