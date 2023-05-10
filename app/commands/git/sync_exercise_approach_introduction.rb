class Git::SyncExerciseApproachIntroduction
  include Mandate

  initialize_with :exercise, :config

  def call
    exercise.update!(
      approach_introduction_authorships: authorships,
      approach_introduction_contributorships: contributorships
    )
  end

  private
  def authorships
    ::User.with_data.where(data: { github_username: config[:authors].to_a }).
      map { |author| ::Exercise::Approach::Introduction::Authorship::Create.(exercise, author) }
  end

  def contributorships
    ::User.with_data.where(data: { github_username: config[:contributors].to_a }).
      map { |contributor| ::Exercise::Approach::Introduction::Contributorship::Create.(exercise, contributor) }
  end
end
