# Opts an action in to cross-origin isolation, which is what unlocks
# SharedArrayBuffer (and the Atomics built on it) in the browser.
#
# Both headers are needed - the browser only flips crossOriginIsolated once it
# has seen COOP and COEP together.
#
# We use `credentialless` rather than `require-corp` for COEP because it fails
# gracefully: a cross-origin subresource without Cross-Origin-Resource-Policy
# is fetched without credentials rather than being blocked outright. Under
# `require-corp` every image in a user's markdown, every third-party script,
# and every stylesheet from the assets host would have to carry CORP or be
# CORS-fetched, and anything that didn't would simply not load.
#
# Cross-origin *iframes* are strict under both values though: the embedded
# document must send its own COEP, or the element must carry the
# `credentialless` attribute. See VimeoEmbed.tsx.
#
# IMPORTANT: these headers only do anything on a real browser navigation. A
# Turbo visit swaps the body of the existing document, so the document keeps
# whatever isolation it was loaded with. Any action using this must therefore
# also opt out of Turbo - see Tracks::ExercisesController.
module CrossOriginIsolation
  extend ActiveSupport::Concern

  private
  def cross_origin_isolate!
    response.set_header("Cross-Origin-Opener-Policy", "same-origin")
    response.set_header("Cross-Origin-Embedder-Policy", "credentialless")
  end
end
