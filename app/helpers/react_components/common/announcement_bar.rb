module ReactComponents
  module Common
    class AnnouncementBar < ReactComponent
      def to_s
        super("common-announcement-bar", {
          endpoint: Exercism::Routes.announcement_page_url
        })
      end
    end
  end
end
