module ReactComponents
  module Insiders
    class InsidersStatus < ReactComponent
      def to_s
        super(
          "insiders-status",
          {
            status: current_user.insiders_status,
            donate_link: Exercism::Routes.donate_path(anchor: "anchor-donate"),
            insiders_status_request: Exercism::Routes.api_user_url(current_user),
            activate_insider_link: Exercism::Routes.activate_insiders_api_user_path
          }
        )
      end
    end
  end
end
