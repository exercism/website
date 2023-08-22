let retryCount = 0
const MAX_RETRIES = 50

export function showSiteFooter(): void {
  const elems = document.body.getElementsByClassName('c-react-component')
  for (const elem of elems) {
    console.log(elem.childElementCount)

    if (elem.childElementCount === 0 && retryCount < MAX_RETRIES) {
      retryCount++
      setTimeout(showSiteFooter, 50)
      return
    }
  }

  /* Now everything is rendered, it might take the browser
   * a few ms to actually paint everything. In my testing, it's
   * always between 50-100ms, so I've added a little extra to be safe*/
  setTimeout(displayFooter, 150)
  retryCount = 0
}

const displayFooter = () => {
  const footerElement = document.getElementById('site-footer')
  if (footerElement !== null) {
    footerElement.style.display = 'block'
  }
}
