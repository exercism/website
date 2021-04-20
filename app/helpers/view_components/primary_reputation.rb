module ViewComponents
  class PrimaryReputation < ViewComponent
    def initialize(user, has_notification: false)
      super()

      @user = user
      @has_notification = has_notification
    end

    # TODO: Move this to React and add Websockets
    def to_s
      link_to("#", class: "c-primary-reputation", 'aria-label': "#{@user.reputation} reputation") do
        tags = [
          tag.div(class: "--inner") do
            icon(:reputation, "Reputation") +
              tag.span(user.formatted_reputation)
          end
        ]
        tags << tag.div('', class: "--notification") if has_notification

        safe_join(tags)
      end
    end

    private
    attr_reader :user, :has_notification
  end
end
