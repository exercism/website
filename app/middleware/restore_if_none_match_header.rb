class RestoreIfNoneMatchHeader
  def initialize(app)
    @app = app
  end

  def call(env)
    if_none_match = env['HTTP_X_IF_NONE_MATCH']
    env['HTTP_IF_NONE_MATCH'] ||= if_none_match if if_none_match.present?

    @app.(env)
  end
end
