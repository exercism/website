class Cache::GenerateEtag
  include Mandate

  def initialize(args, current_user)
    @args = Array.wrap(args)
    @current_user = current_user
  end

  def call
    extra_args + args
  end

  private
  attr_reader :args, :current_user

  def extra_args
    [
      Cache::KeyForFooter.(current_user),
      current_user&.preferences&.theme
    ].compact
  end
end
