module ViewComponents
  class Reputation < ViewComponent
    def initialize(user, primary: false, has_notification: false)
      @user = user
      @primary = primary
      @has_notification = has_notification
    end

    def to_s
      classes = ["c-reputation"]
      classes << "--primary" if primary

      link_to("#", class: classes.join(" "), 'aria-label': "#{@user.reputation} reputation") do
        tags = [
          tag.div(class: "--inner") do
            icon(:reputation, "Reputation") +
              tag.span(user.reputation)
          end
        ]
        tags << tag.div('', class: "--notification") if has_notification

        safe_join(tags)
      end
    end

    private
    attr_reader :user, :primary, :has_notification
  end
end
