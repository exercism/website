class Bootcamp::UserProject::CreateAll
  include Mandate

  initialize_with :user

  def call
    Bootcamp::Project.find_each do |project|
      Bootcamp::UserProject::Create.defer(user, project)
    end
  end
end
