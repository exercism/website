export function showSiteFooter(): void {
  elems = document.body.getElementsByClassName('c-react-component')
  for (let elem of elems) {
    if (elem.children.length == 0) {
      setTimeout(showSiteFooter, 50)
      return
    }
  }

  const footerElement = document.getElementById('site-footer')
  if (footerElement !== null) {
    footerElement.style.display = 'block'
  }
}
