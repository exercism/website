export function scrollIntoView(): void {
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
}

function scrollElementsIntoView(elements: NodeListOf<Element>): void {
  elements.forEach((element) => {
    if (isInViewport(element)) {
      return
    }

    element.scrollIntoView({
      behavior: 'instant',
      block: 'center',
      inline: 'center',
    })
  })
}

function isInViewport(element) {
  const rect = element.getBoundingClientRect()
  return (
    rect.top >= 0 &&
    rect.left >= 0 &&
    rect.bottom <=
      (window.innerHeight || document.documentElement.clientHeight) &&
    rect.right <= (window.innerWidth || document.documentElement.clientWidth)
  )
}
