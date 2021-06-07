module ReactComponents
  module Common
    class Walkthrough < ReactComponent
      def to_s
        super("common-walkthrough", { html: Git::WebsiteCopy.new.walkthrough })
      end
    end
  end
end
