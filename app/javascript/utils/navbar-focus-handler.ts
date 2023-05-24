export function handleNavbarFocus(): void {
  document.addEventListener('DOMContentLoaded', function () {
    let shiftTabPressed = false
    const navElements = document.querySelectorAll<HTMLElement>(
      '.nav-element-focusable'
    )
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

      navElement.addEventListener('focus', () => {
        // if (navElement && navElement.nodeName === 'SPAN') {
        //   const dropdown = navElement.nextElementSibling
        //   if (dropdown && !shiftTabPressed) {
        //     const firstLink = dropdown.querySelector(
        //       'ul li a'
        //     ) as HTMLAnchorElement
        //     if (firstLink) {
        //       setTimeout(() => firstLink.focus(), 50)
        //       return
        //     }
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

      if (event.key === 'Tab' && event.shiftKey) {
        shiftTabPressed = true
      } else {
        shiftTabPressed = false
      }
    })
  })
}
