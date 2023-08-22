let retryCount = 0
const MAX_RETRIES = 50

export function showSiteFooter(): void {
  const elems = document.body.getElementsByClassName('c-react-component')
  for (const elem of elems) {
    if (elem.childElementCount === 0 && retryCount < MAX_RETRIES) {
      retryCount++
      setTimeout(showSiteFooter, 50)
      return
    }
  }

  displayFooter()
  retryCount = 0
}

const displayFooter = () => {
  const footerElement = document.getElementById('site-footer')
  if (footerElement !== null) {
    footerElement.style.display = 'block'
  }
}
