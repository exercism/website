type ScrollAxis = 'X' | 'Y'

export function scrollIntoView(): void {
  collectAndScroll('X')
  collectAndScroll('Y')

  const docsSideMenuTrigger = document.getElementById(
    'side-menu-trigger'
  ) as HTMLInputElement | null
  if (docsSideMenuTrigger) {
    docsSideMenuTrigger.addEventListener('change', () => {
      if (docsSideMenuTrigger.checked) {
        collectAndScroll('Y')
      }
    })
  }
}

const collectAndScroll = (axis: ScrollAxis) => {
  document
    .querySelectorAll<HTMLElement>('[data-scrollable-container="true"]')
    .forEach((container) => {
      console.log('containr', container)
      const elements = Array.from(
        container.querySelectorAll<HTMLElement>(
          `[data-scroll-into-view="${axis}"]`
        )
      )

      if (elements.length > 0) {
        scrollElementsIntoView(elements, container, axis)
      }
    })
}

function scrollElementsIntoView(
  elements: HTMLElement[],
  container: HTMLElement,
  axis: ScrollAxis
): void {
  elements.forEach((element) => {
    scrollToElementWithinContainer(element, container, axis)
  })
}

function scrollToElementWithinContainer(
  element: HTMLElement,
  container: HTMLElement,
  axis: ScrollAxis
) {
  const elementRect = element.getBoundingClientRect()
  const containerRect = container.getBoundingClientRect()

  if (axis === 'Y') {
    const topPosition =
      elementRect.top - containerRect.top + container.scrollTop
    container.scrollTop = topPosition - container.clientHeight / 2
  } else if (axis === 'X') {
    const leftPosition =
      elementRect.left - containerRect.left + container.scrollLeft
    container.scrollLeft = leftPosition - container.clientWidth / 2
  }
}

function _isInViewport(element: HTMLElement): boolean {
  const rect = element.getBoundingClientRect()
  return (
    rect.top >= 0 &&
    rect.left >= 0 &&
    rect.bottom <=
      (window.innerHeight || document.documentElement.clientHeight) &&
    rect.right <= (window.innerWidth || document.documentElement.clientWidth)
  )
}
