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
    if (elem.childElementCount > 0) {
      continue
    }

    // ...otherwise wait another 50ms and try again
    retryCount++
    setTimeout(showSiteFooter, 50)
    return
  }

  /*
   * Now everything is rendered, it might take the browser
   * a few ms to actually paint everything. In my testing, it's
   * always between 50-100ms, so I've added a little extra to be safe.
   */
  setTimeout(displayFooter, 150)
  retryCount = 0
}

const displayFooter = () => {
  const footerElement = document.getElementById('site-footer')
  if (footerElement !== null) {
    footerElement.style.display = 'block'
  }
}
