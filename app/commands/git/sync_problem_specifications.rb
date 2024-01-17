class Git::SyncProblemSpecifications
  include Mandate

  queue_as :default

  def call
    repo.update!

    # repo.config[:posts].to_a.each do |data|
    #   create_or_update_post(data)
    # end

    # repo.config[:stories].to_a.each do |data|
    #   create_or_update_story(data)
    # end
  end

  memoize
  def repo = Git::ProblemSpecifications.new
end
