import { assetUrl } from './assets'
import { copyToClipboard } from './copyToClipboard'

export function appendAnchorButtonsToDocsHeaders() {
  const currentPath = window.location.pathname

  if (currentPath.includes('/docs')) {
    const docsHeaders = document.querySelectorAll('[id^="h-"')

    const anchorIcon = document.createElement('img')
    anchorIcon.src = assetUrl('icons/link.svg')
    anchorIcon.height = 16
    anchorIcon.width = 16

    const button = document.createElement('button')
    button.className = 'copy-header-link-button'
    button.appendChild(anchorIcon)

    docsHeaders.forEach((headerElement) => {
      const header = headerElement as HTMLElement
      header.classList.add('anchored-header')

      const buttonClone = button.cloneNode(true) as HTMLElement
      const headerText = header.textContent || header.innerText
      buttonClone.setAttribute(
        'aria-label',
        `Copy link for header: ${headerText}`
      )
      header.insertBefore(buttonClone, header.firstChild)

      buttonClone.addEventListener('click', (event) => {
        event.preventDefault()
        const baseURL = window.location.href.split('#')[0]
        copyToClipboard(baseURL + `#${header.id}`)
      })
    })
  }
}
