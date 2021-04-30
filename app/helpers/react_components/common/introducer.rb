module ReactComponents
  module Common
    class Introducer < ReactComponent
      initialize_with :id, :icon

      def to_s
        return if hidden?

        super("common-introducer", {
          icon: icon,
          content: content,
          endpoint: Exercism::Routes.hide_temp_introducer_path(id)
        })
      end

      def content
        capture_haml { block.() }
      end

      # TODO: This is just a temporary implementation
      def hidden?
        (context.session[:hidden_introducers] || []).include?(id.to_s)
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
