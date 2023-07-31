class AssembleNotificationsList
  include Mandate

  initialize_with :user, :params

  def self.keys
    %i[page per_page order for_header]
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

  private
  memoize
  def notifications
    params[:for_header] ? header_notifications : page_notifications
  end

  # This is much more efficient than the page_notifications version below
  # We want to order by unread then read but this is slow.
  # So we create a Set, populate it with the first five unread,
  # then fill with the most recent first 5 (regardless of status).
  # Then we just look at the first 5 things in the set.
  def header_notifications
    ids = Set.new(user.notifications.unread.order(id: :desc).limit(5).pluck(:id))

    # TODO: This needs a desc index adding
    ids += user.notifications.limit(10).read.order(id: :desc).pluck(:id) unless ids.size == 5

    ids = ids.to_a # Sets don't have `.index`

    notifications = User::Notification.where(id: ids).
      sort_by { |n| ids.index(n.id) }[0, 5]

    Kaminari.paginate_array(notifications, total_count: notifications.size).page(1).per(5)
  end

  # This needs a descending index adding and performance testing against a major user
  def page_notifications
    User::Notification::Retrieve.(
      user,
      page: params[:page],
      per_page: params[:per_page],
      order: params[:order]
    )
  end
end
