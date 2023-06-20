export function scrollToSelectedAdminMenuElement(): void {
  document.addEventListener('turbo:load', function () {
    const element = document.querySelector('.c-about-nav #selected-item')
    if (element) {
      element.scrollIntoView({
        behavior: 'instant',
        block: 'center',
        inline: 'center',
      })
    }
  })
}
