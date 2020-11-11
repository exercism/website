module ViewComponents
  class ViewComponent
    extend Mandate::Memoize
    extend Mandate::InitializerInjector

    delegate :current_user,
      :safe_join,
      :tag, :link_to, :button_to,
      :graphical_icon, :icon, :track_icon, :exercise_icon,
      to: :view_context

    # This is called when you called `render SomeComponent.new(...)`
    # It sets the view context, which can then be used for things
    # like getting the current user, or authentication tokens
    def render_in(context, *_args)
      @view_context = context
      to_s
    end

    private
    attr_reader :view_context
  end
end
