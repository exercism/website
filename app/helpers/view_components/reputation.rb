module ViewComponents
  class Reputation < ViewComponent
    initialize_with :user

    def to_s
      tag.div(class: "c-reputation", 'aria-label': "#{@user.reputation} reputation") do
        icon(:reputation, "Reputation") +
          tag.span(user.reputation)
      end
    end
  end
end
