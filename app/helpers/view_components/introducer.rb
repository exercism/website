module ViewComponents
  class Introducer < ViewComponent
    initialize_with :id, :icon_name

    def to_s
      tag.div(class: "c-introducer") do
        safe_join(
          [decorative_icon, content, close_button]
        )
      end
    end

    def decorative_icon
      graphical_icon(icon_name, category: "graphics", css_class: "visual-icon")
    end

    def content
      tag.div(class: "info") do
        capture_haml { block.() }
      end
    end

    def close_button
      tag.button class: "close" do
        icon('close', "Permanently hide this introducer")
      end
    end

    # This is called when you called `render SomeComponent.new(...)`
    # It sets the view context, which can then be used for things
    # like getting the current user, or authentication tokens
    def render_in(context, *args, &block)
      @block = block

      super(context, *args)
    end

    private
    attr_reader :block
  end
end
