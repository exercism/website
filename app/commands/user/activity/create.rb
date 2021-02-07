class User::Activity
  class Create
    include Mandate

    initialize_with :type, :user, :params

    def initialize(type, user, params = {})
      @type = type
      @user = user
      @params = params.dup
    end

    def call
      klass = "user/activities/#{type}_activity".camelize.constantize

      klass.create!(
        user: user,
        track: params.delete(:track),
        solution: params.delete(:solution),
        params: params
      ).tap do
        # TODO: Broadcast new activity
        # AcivitiiesChannel.broadcast_changed(user)
      end
    end

    private
    attr_reader :type, :user, :params
  end
end
