export function handleNavbarFocus(): void {
  document.addEventListener('DOMContentLoaded', function () {
    const navElements = document.querySelectorAll<HTMLElement>('.nav-element')
    let currentMouseOverElement: HTMLElement | null = null

    navElements.forEach((navElement) => {
      navElement.addEventListener('mouseover', () => {
        removeFocusFromOtherElements(navElement)
        currentMouseOverElement = navElement
        document.body.classList.remove('keyboard-navigation')
      })

      navElement.addEventListener('mouseleave', () => {
        currentMouseOverElement = null
      })

      navElement.addEventListener('focus', (event: FocusEvent) => {
        // const target = event.target as HTMLElement

        // if (target && target.matches('ul li a')) {
        //   event.stopPropagation()
        // } else {
        //   const firstMenuItem = target.querySelector('ul li a') as HTMLElement
        //   if (firstMenuItem) {
        //     firstMenuItem.focus()
        //   }
        // }

        if (currentMouseOverElement) {
          const dropdown = currentMouseOverElement.querySelector<HTMLElement>(
            '.nav-element-dropdown'
          )
          if (dropdown) {
            dropdown.classList.add('hidden')
          }
        }

        removeFocusFromOtherElements(navElement)
      })

      navElement.addEventListener('blur', () => {
        if (currentMouseOverElement) {
          const dropdown = currentMouseOverElement.querySelector<HTMLElement>(
            '.nav-element-dropdown'
          )
          if (dropdown) {
            dropdown.classList.remove('hidden')
          }
        }
      })
    })

    function removeFocusFromOtherElements(currentElement: HTMLElement) {
      navElements.forEach((otherElement) => {
        if (otherElement !== currentElement) {
          otherElement.blur()
          const focusableChildren =
            otherElement.querySelectorAll<HTMLElement>('[tabindex="0"]')
          focusableChildren.forEach((child) => {
            child.blur()
          })
        }
      })
    }

    document.addEventListener('keydown', function (event: KeyboardEvent) {
      if (event.key === 'Tab') {
        document.body.classList.add('keyboard-navigation')
      }
    })
  })
}
