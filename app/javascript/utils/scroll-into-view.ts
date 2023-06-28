export function scrollIntoView(): void {
  document.addEventListener('turbo:load', function () {
    const elements = document.querySelectorAll('[data-scroll-into-view="true"]')

    if (elements.length > 0) {
      scrollElementsIntoView(elements)
    }

    const docsSideMenuTrigger = document.getElementById(
      'side-menu-trigger'
    ) as HTMLInputElement

    // when docs side menu is opened, rerun the scroll fn
    if (docsSideMenuTrigger) {
      docsSideMenuTrigger.addEventListener('change', function () {
        if (docsSideMenuTrigger.checked) {
          scrollElementsIntoView(elements)
        }
      })
    }
  })
}

function scrollElementsIntoView(elements: NodeListOf<Element>): void {
  elements.forEach((element) => {
    element.scrollIntoView({
      behavior: 'instant',
      block: 'center',
      inline: 'center',
    })
  })
}
