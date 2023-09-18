module ReactComponents
  module Common
    # This component can be used in two ways:
    #
    # 1. As a block:
    #   = render ReactComponents::Common::Modal.new do
    #     %p Some text
    #     %button{ data: { modal_close: true } } Close
    #
    # 2. As a template with a partial name, and an optional has of locals:
    #   = render ReactComponents::Common::Modal.new('subtemplate', name: 'iHiD')
    #
    # In either case, adding a close button is done via:
    # %button{ data: { modal_close: true } }

    class Modal < ReactComponent
      def initialize(template = nil, locals = nil)
        super()

        @template = template
        @locals = locals
      end

      # This is called when you called `render SomeComponent.new(...)`
      # It sets the view context, which can then be used for things
      # like getting the current user, or authentication tokens
      def render_in(context, *args, &block)
        @block = block

        super(context, *args)
      end

      def to_s
        super("common-modal", { html: })
      end

      private
      attr_reader :template, :locals, :block

      def html
        if template
          render(partial: template, locals:)
        else
          capture_haml { block.() }.html_safe
        end
      end
    end
  end
end
