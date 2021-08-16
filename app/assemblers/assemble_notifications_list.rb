class AssembleNotificationsList
  include Mandate

  initialize_with :user, :params

  def self.keys
    %i[page per_page order]
  end

  def call
    SerializePaginatedCollection.(
      notifications,
      data: notifications.map(&:rendering_data),
      meta: {
        links: {
          all: Exercism::Routes.notifications_url
        },
        unread_count: user.notifications.unread.count
      }
    )
  end

  memoize
  def notifications
    User::Notification::Retrieve.(
      user,
      page: params[:page],
      per_page: params[:per_page],
      order: params[:order]
    )
  end
end
