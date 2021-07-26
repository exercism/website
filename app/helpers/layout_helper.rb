module LayoutHelper
  def body_class
    classes = []
    classes << "devise" if devise_controller?
    classes << "namespace-#{namespace_name}"
    classes << "controller-#{controller_name || 'none'}"
    classes << "action-#{action_name}"
    classes << "theme-light"
    user_signed_in? ? classes << "user-signed_in" : classes << "user-signed_out"
    classes.join(" ")
  end

  def js_packs
    [
      ('application' if landing_page?),
      ('internal' if user_signed_in?),
      ('editor' if render_editor_js_pack?),
      ('test' if render_test_js_pack?)
    ].compact
  end

  def deferred_js_packs
    all = %w[application internal editor]
    all - js_packs
  end

  # Always include application in the JS pack
  def css_packs
    (js_packs + ['application']).uniq
  end

  def landing_page?
    namespace_name.nil? && controller_name == "pages" && action_name == "index"
  end

  def render_editor_js_pack?
    return true if namespace_name == "tracks" && controller_name == "exercises" && action_name == "edit"
    return true if namespace_name == "test" && controller_name == "editor" && action_name == "show"

    false
  end

  def render_test_js_pack?
    namespace_name == "test"
  end
end
