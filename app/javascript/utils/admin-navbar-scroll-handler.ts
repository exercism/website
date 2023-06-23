export function scrollToSelectedAdminMenuElement(): void {
  document.addEventListener('turbo:load', function () {
    const element = document.getElementById('scroll-into-view-item')
    if (element) {
      element.scrollIntoView({
        behavior: 'instant',
        block: 'center',
        inline: 'center',
      })
    }
  })
}
