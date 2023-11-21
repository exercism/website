type ScrollAxis = 'X' | 'Y'

export function scrollIntoView(): void {
  collectAndScroll('X')
  collectAndScroll('Y')

  // when docs side menu is opened, rerun the scroll fn
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

const axisProps = {
  X: {
    size: 'clientWidth',
    scroll: 'scrollLeft',
    start: 'left',
  },
  Y: {
    size: 'clientHeight',
    scroll: 'scrollTop',
    start: 'top',
  },
}

function scrollToElementWithinContainer(
  element: HTMLElement,
  container: HTMLElement,
  axis: ScrollAxis
) {
  const elementRect = element.getBoundingClientRect()
  const containerRect = container.getBoundingClientRect()

  const { size, scroll, start } = axisProps[axis]

  const position = elementRect[start] - containerRect[start] + container[scroll]
  container[scroll] = position - container[size] / 2
}
