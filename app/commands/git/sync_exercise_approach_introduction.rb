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
    ::User.where(github_username: config[:authors].to_a).
      map { |author| ::Exercise::Approaches::IntroductionAuthorship::Create.(exercise, author) }
  end

  def contributorships
    ::User.where(github_username: config[:contributors].to_a).
      map { |contributor| ::Exercise::Approaches::IntroductionContributorship::Create.(exercise, contributor) }
  end
end
