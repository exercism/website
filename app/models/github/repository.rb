class Github::Repository
  include Mandate

  initialize_with :name, :type

  def name_with_owner = "exercism/#{name}"

  memoize
  def track = Track.for_repo(name)
end
