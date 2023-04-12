module ReactComponents
  module Insiders
    class InsidersStatus < ReactComponent
      def to_s
        super(
          "insiders-status",
          {
            status: 'unset',
            donate_link: Exercism::Routes.donate_path,
            insiders_status_request: Exercism::Routes.api_user_url(current_user)
          }
        )
      end
    end
  end
end
