class Bootcamp::UserProject::Create
  include Mandate

  initialize_with :user, :project

  def call
    find_or_create.tap do |up|
      Bootcamp::UserProject::UpdateStatus.(up)
    end
  end

  def find_or_create
    Bootcamp::UserProject.create!(user:, project:)
  rescue StandardError
    Bootcamp::UserProject.find_by!(user:, project:)
  end
end
