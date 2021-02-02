import React, { useState, useEffect, useRef, useMemo } from 'react'
import { usePanel } from '../../hooks/use-panel'
import { v4 as uuidv4 } from 'uuid'

type MenuButton = {
  label: string
  className: string
  html: string
}

type MenuItem = {
  html: string
  className: string
}

export const Dropdown = ({
  menuButton,
  menuItems,
}: {
  menuButton: MenuButton
  menuItems: MenuItem[]
}): JSX.Element => {
  const { open, setOpen, buttonRef, panelRef, styles, attributes } = usePanel()
  const [focusIndex, setFocusIndex] = useState<number | null>(null)
  const menuItemElementsRef = useRef<HTMLLIElement[]>([])
  const id = useMemo(() => {
    return uuidv4()
  }, [])

  const handleButtonKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        setOpen(true)
        setFocusIndex(0)

        break
      case 'ArrowUp':
        e.preventDefault()
        setOpen(true)
        setFocusIndex(menuItems.length - 1)

        break
    }
  }

  const handleItemKeyDown = (e: React.KeyboardEvent, index: number) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        setFocusIndex((index + menuItems.length + 1) % menuItems.length)

        break
      case 'ArrowUp':
        e.preventDefault()
        setFocusIndex((index + menuItems.length - 1) % menuItems.length)

        break
      case 'Tab':
        setOpen(false)

        break
      case 'Escape':
        e.preventDefault()
        setOpen(false)
        setFocusIndex(null)

        break
      case ' ':
      case 'Enter': {
        e.preventDefault()

        setOpen(false)

        const link = menuItemElementsRef.current[index]?.querySelector('a')
        link?.click()

        break
      }
    }
  }

  const handleMenuItemMount = (
    instance: HTMLLIElement | null,
    index: number
  ) => {
    if (!instance) {
      return
    }

    menuItemElementsRef.current[index] = instance
  }

  useEffect(() => {
    if (focusIndex === null) {
      buttonRef.current?.focus()

      return
    }

    menuItemElementsRef.current[focusIndex].focus()
  }, [open, focusIndex, buttonRef])

  return (
    <React.Fragment>
      <button
        className={`${menuButton.className}`}
        aria-controls={id}
        aria-haspopup
        aria-label={menuButton.label}
        aria-expanded={open ? true : undefined}
        dangerouslySetInnerHTML={{ __html: menuButton.html }}
        ref={buttonRef}
        onKeyDown={handleButtonKeyDown}
        onClick={() => {
          setOpen(!open)
        }}
      />
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        <ul
          className={`${menuButton.className}-dropdown`}
          id={id}
          role="menu"
          hidden={!open}
        >
          {menuItems.map((item, i) => {
            return (
              <li
                ref={(instance) => handleMenuItemMount(instance, i)}
                key={item.html}
                dangerouslySetInnerHTML={{ __html: item.html }}
                onKeyDown={(e) => handleItemKeyDown(e, i)}
                tabIndex={-1}
                role="menuitem"
                className={item.className}
              />
            )
          })}
        </ul>
      </div>
    </React.Fragment>
  )
}
