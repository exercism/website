let retryCount = 0
const MAX_RETRIES = 50

export function showSiteFooter(): void {
  // If we're over our recount try, just show the footer
  if (retryCount >= MAX_RETRIES) {
    displayFooter()
    return
  }

  const elems = document.body.getElementsByClassName('c-react-component')
  for (const elem of elems) {
    // If this elem is hydrated, move onto the next one...
    if (
      elem.childElementCount > 0 &&
      elem.children[0].classList != 'c-loading-suspense'
    ) {
      continue
    }

    // ...otherwise wait another 10ms and try again
    retryCount++
    setTimeout(showSiteFooter, 10)
    return
  }

  /*
   * Now everything is rendered, display the footer!
   */
  displayFooter()
  retryCount = 0
}

const displayFooter = () => {
  const footerElement = document.getElementById('site-footer')
  if (footerElement !== null) {
    footerElement.style.display = 'block'
  }
}
