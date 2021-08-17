// eslint-disable-next-line @typescript-eslint/no-var-requires
require('@rails/ujs').start()
// eslint-disable-next-line @typescript-eslint/no-var-requires
require('@rails/activestorage').start()

import '@hotwired/turbo-rails'
import { navigator } from '@hotwired/turbo'

document.addEventListener('DOMContentLoaded', function () {
  ;(window as any).DOMLoaded = true
})
