// eslint-disable-next-line @typescript-eslint/no-var-requires
require('@rails/ujs').start()
// eslint-disable-next-line @typescript-eslint/no-var-requires
require('@rails/activestorage').start()

import '@hotwired/turbo-rails'
import { navigator } from '@hotwired/turbo'

document.addEventListener('DOMContentLoaded', function () {
  ;(window as any).DOMLoaded = true
})

document.addEventListener('turbo:before-fetch-request', (e) => {
  const frame = (e as any).detail.fetchOptions.headers['Turbo-Frame']
  if (!frame) {
    return
  }

  const url = (e as any).detail.url
  if (url != null) {
    navigator.history.push(new URL(url))
  }
})
