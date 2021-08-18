export const bindTurboFrameEvents = () => {
  document.addEventListener('turbo:load', () => {
    // Clear all the old observers
    if (!window.turboFrameObservers) {
      window.turboFrameObservers = []
    }
    window.turboFrameObservers.forEach((o) => o.disconnect())
    window.turboFrameObservers = []

    // Once the turbo loads we need to monitor the turbo-frame
    // There are no events for this, so we use a mutation observer
    // instead.
    const targetNode = document.getElementById('site-content')
    const observer = new MutationObserver(() => {
      console.log('Reacting to site-content change')

      if (!targetNode) {
        return
      }

      // Update the URL
      const url = targetNode.querySelector('meta[name="exercism-url"]').content
      if (url != null && Turbo.navigator.history.location.href != url) {
        console.log('Updating URL to ' + url)
        Turbo.navigator.history.push(new URL(url))
      }

      // Update the Body class
      const bodyClass = targetNode.querySelector(
        'meta[name="exercism-body-class"]'
      ).content
      document.body.className = bodyClass

      // Update the page title
      const newTitle = targetNode.querySelector('meta[name="exercism-title"]')
        .content
      document.title = newTitle

      console.log('Firing frameload event')
      var event = new CustomEvent('turbo:frameload', {})
      document.dispatchEvent(event)
    })
    observer.observe(targetNode, { childList: true })

    if (!window.turboFrameObservers) {
      window.turboFrameObservers = []
    }
    window.turboFrameObservers.push(observer)
  })
}
