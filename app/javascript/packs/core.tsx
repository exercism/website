import '@hotwired/turbo-rails'

// As we're sensitive to the order of things across different packs
// we set a window-level constant to record when turbo has loaded
// so that other packs that haven't yet rendered events can respond to them
document.addEventListener('turbo:load', () => (window.turboLoaded = true))

function showLocaleBanner() {
  const banner = document.getElementById('locale-bar') as HTMLElement | null
  if (!banner) return

  // LocalStorage keys
  const dismissedKey = 'localeBannerDismissedxx'

  // Skip if user has dismissed before
  if (localStorage.getItem(dismissedKey) === 'true') return

  // Add hidden class to all annoucncement bars
  for (const el of document.getElementsByClassName('announcement-bar')) {
    ;(el as HTMLElement).style.display = 'none'
  }

  // Show banner
  banner.classList.remove('hidden')
  banner.style.display = '' // remove inline display:none

  // Add "No" button dynamically if not already there
  const hideThis = banner.querySelector('.js-hide-this')
  if (hideThis) {
    hideThis.addEventListener('click', (e) => {
      e.preventDefault()
      localStorage.setItem(dismissedKey, 'true')
      banner.remove()

      // If there's another banner, show it.
      const otherAnnouncement = document.querySelector('.announcement-bar')
      if (otherAnnouncement) {
        otherAnnouncement.style.display = 'block'
      }
    })
  }
}
showLocaleBanner()
