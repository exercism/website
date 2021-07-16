// eslint-disable-next-line @typescript-eslint/no-var-requires
require('@rails/ujs').start()
// eslint-disable-next-line @typescript-eslint/no-var-requires
require('turbolinks').start()
// eslint-disable-next-line @typescript-eslint/no-var-requires
require('@rails/activestorage').start()

document.addEventListener('DOMContentLoaded', function () {
  ;(window as any).DOMLoaded = true
})
