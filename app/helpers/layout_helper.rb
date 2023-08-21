module LayoutHelper
  def js_packs
    [
      ('application' unless landing_page?),
      ('internal' if user_signed_in?),
      ('test' if render_test_js_pack?)
    ].compact
  end

  # Always include application in the JS pack
  def css_packs
    (js_packs + ['application']).uniq
  end

  def render_test_js_pack?
    namespace_name == "test"
  end
end
