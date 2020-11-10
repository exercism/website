class User::Activity
  class Create
    include Mandate

    initialize_with :type, :user, :params

    def call
      klass = "user/activities/#{type}_activity".camelize.constantize

      klass.create!(
        user: user,
        track: params[:track],
        params: params
      ).tap do
        # TODO: Broadcast new activity
        # AcivitiiesChannel.broadcast_changed(user)
      end
    end
  end
end
