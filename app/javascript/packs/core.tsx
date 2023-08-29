// eslint-disable-next-line @typescript-eslint/no-var-requires
// require('@rails/ujs').start()
// // eslint-disable-next-line @typescript-eslint/no-var-requires
// require('@rails/activestorage').start()

import '@hotwired/turbo-rails'

// As we're sensitive to the order of things across different packs
// we set a window-level constant to record when turbo has loaded
// so that other packs that haven't yet rendered events can respond to them
document.addEventListener('turbo:load', () => (window.turboLoaded = true))
