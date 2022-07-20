class Cohort::Join
  include Mandate

  initialize_with :user, :cohort, :introduction

  def call
    # TODO: make this safe against race issues
    CohortMembership.create!(user:, cohort:, status:, introduction:)
  rescue ActiveRecord::RecordNotUnique
    CohortMembership.find_by(user:, cohort:)
  end

  private
  def status = cohort.can_be_joined? ? :enrolled : :on_waiting_list
end
