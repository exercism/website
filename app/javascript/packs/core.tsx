import '@hotwired/turbo-rails'

// As we're sensitive to the order of things across different packs
// we set a window-level constant to record when turbo has loaded
// so that other packs that haven't yet rendered events can respond to them
document.addEventListener('turbo:load', () => (window.turboLoaded = true))

import { initLocalePrefLinks } from '@/utils/locale-pref-cookie'
initLocalePrefLinks()
