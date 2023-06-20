export function showSiteFooterOnTurboLoad(): void {
  document.addEventListener('turbo:load', function () {
    const footerElement = document.getElementById('site-footer')
    if (footerElement !== null) {
      footerElement.style.display = 'block'
    }
  })
}
