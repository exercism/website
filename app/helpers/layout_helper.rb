module LayoutHelper
  def js_packs
    [
      ('application' unless landing_page?),
      ('internal' if user_signed_in?),
      ('test' if render_test_js_pack?)
    ].compact
  end

  def render_test_js_pack?
    namespace_name == "test"
  end
end
