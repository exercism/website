class Exercise::Approach::Contributorship::Create
  include Mandate

  initialize_with :approach, :contributor

  def call
    begin
      contributorship = approach.contributorships.create!(contributor:)
    rescue ActiveRecord::RecordNotUnique
      return nil
    end

    User::ReputationToken::Create.defer(contributor, :exercise_approach_contributor, contributorship:)
  end
end
