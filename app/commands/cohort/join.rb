class Cohort::Join
  include Mandate

  initialize_with :user, :cohort, :introduction

  def call
    # TODO: make this safe against race issues
    user.cohort_memberships.create!(cohort:, status:, introduction:)
  rescue ActiveRecord::RecordNotUnique
    # This is fine
  end

  private
  def status = cohort.can_be_joined? ? :enrolled : :on_waiting_list
end
