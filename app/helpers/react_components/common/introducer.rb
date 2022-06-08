module ReactComponents
  module Common
    class Introducer < ReactComponent
      initialize_with :slug, :icon

      def to_s
        return if hidden?

        super("common-introducer", {
          icon:,
          content:,
          endpoint:
        })
      end

      def content
        capture_haml { block.() }
      end

      def hidden?
        current_user&.introducer_dismissed?(slug.to_s)
      end

      def endpoint
        return nil unless user_signed_in?

        Exercism::Routes.hide_api_settings_introducer_path(slug)
      end

      def render_in(context, *args, &block)
        @context = context
        @block = block

        super(context, *args)
      end

      private
      attr_reader :block, :context
    end
  end
end
