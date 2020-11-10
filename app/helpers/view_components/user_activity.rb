module ViewComponents
  class UserActivity < ViewComponent
    initialize_with :activity

    def to_s
      template = activity.class.name.split("::").last.underscore.gsub(/_activity$/, "")
      ApplicationController.render "components/user_activities/#{template}",
        locals: { activity: activity },
        layout: false
    end
  end
end
