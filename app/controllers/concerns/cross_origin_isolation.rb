# Opts an action in to cross-origin isolation, which is what unlocks
# SharedArrayBuffer (and the Atomics built on it) in the browser.
#
# Both headers are needed - the browser only flips crossOriginIsolated once it
# has seen COOP and COEP together.
#
# COEP is `require-corp` rather than `credentialless` because Safari does not
# support `credentialless` at all, and an isolated page has to work everywhere.
# The cost is that `require-corp` is strict: every cross-origin subresource must
# carry Cross-Origin-Resource-Policy or be CORS-fetched, and anything that does
# not is blocked outright rather than fetched without credentials. Our assets
# host sends CORP (see response_header_rules.tf in the terraform repo), but a
# third-party script or an image in a user's markdown will not, and will fail.
#
# That is why this is currently only used by the maintainers' experimental
# editor, and not by the editor students use.
#
# Cross-origin iframes are strict under both values: the embedded document must
# send its own COEP, or the element must carry the `credentialless` attribute.
# See VimeoEmbed.tsx.
#
# IMPORTANT: these headers only do anything on a real browser navigation. A
# Turbo visit swaps the body of the existing document, so the document keeps
# whatever isolation it was loaded with. Any action using this must therefore
# also opt out of Turbo - see the meta tag in the experimental editor's view.
module CrossOriginIsolation
  extend ActiveSupport::Concern

  private
  def cross_origin_isolate!
    response.set_header("Cross-Origin-Opener-Policy", "same-origin")
    response.set_header("Cross-Origin-Embedder-Policy", "require-corp")
  end
end
