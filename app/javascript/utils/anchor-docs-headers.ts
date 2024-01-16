import { assetUrl } from './assets'
import { copyToClipboard } from './copyToClipboard'

export function addAnchorsToDocsHeaders() {
  if (!window.location.pathname.startsWith('/docs')) return

  const docsHeaders = document.querySelectorAll('[id^="h-"')

  docsHeaders.forEach(attachAnchorButton)
}

function attachAnchorButton(headerElement: Element) {
  const header = headerElement as HTMLElement
  header.classList.add('anchored-header')

  const button = createAnchorButton(header)
  header.insertBefore(button, header.firstChild)

  button.addEventListener('click', (event) => handleButtonClick(event, header))
}

function createAnchorButton(header: HTMLElement): HTMLElement {
  const button = document.createElement('button')
  button.className = 'copy-header-link-button'

  const icon = createAnchorIcon()
  button.appendChild(icon)

  const headerText = header.textContent || header.innerText
  button.setAttribute('aria-label', `Copy link for header: ${headerText}`)

  return button
}

function createAnchorIcon(): HTMLImageElement {
  const icon = document.createElement('img')
  icon.src = assetUrl('icons/link.svg')
  icon.height = 16
  icon.width = 16

  return icon
}

function handleButtonClick(event: Event, header: HTMLElement) {
  event.preventDefault()

  const baseURL = window.location.href.split('#')[0]
  const copyFeedback = document.createElement('span')
  copyFeedback.className = 'copy-header-link-feedback'

  copyToClipboard(baseURL + `#${header.id}`)
    .then(() => displayFeedback(copyFeedback, header, 'Copied!'))
    .catch(() => displayFeedback(copyFeedback, header, 'Failed to copy!'))
}

function displayFeedback(
  feedbackElem: HTMLElement,
  header: HTMLElement,
  message: string
) {
  feedbackElem.innerText = message
  header.insertBefore(feedbackElem, header.firstChild)

  setTimeout(() => header.removeChild(feedbackElem), 1000)
}
