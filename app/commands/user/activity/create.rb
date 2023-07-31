class User::Activity::Create
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
      user:,
      solution: params.delete(:solution),
      params:
    ).tap do
      # TODO: (Optional) Broadcast new activity
      # ActivitiesChannel.broadcast_changed!(user)
    end
  end

  private
  attr_reader :type, :user, :params
end
