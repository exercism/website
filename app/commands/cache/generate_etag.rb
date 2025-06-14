class Cache::GenerateEtag
  include Mandate

  def initialize(args, _current_user)
    @args = Array.wrap(args)
  end

  def call
    [
      Cache::KeyForFooter.(current_user)
    ] + args
  end

  attr_reader :args, :current_user
end
