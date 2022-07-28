class Github::Repository
  include Mandate

  attr_reader :name, :type

  def initialize(name, type)
    @name = name
    @type = type
  end

  memoize
  def name_with_owner = "exercism/#{name}"

  memoize
  def track = Track.for_repo(name)

  def ==(other) = self.name  == other.name && self.type == other.type
  def <=>(other) = self.name <=> other.name
  def hash = [name, type].hash
  def eql?(other) = self == other
end
