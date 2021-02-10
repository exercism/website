import React, {
  useState,
  useEffect,
  useMemo,
  useRef,
  KeyboardEvent,
} from 'react'
import { usePanel } from '../../hooks/use-panel'
import { v4 as uuidv4 } from 'uuid'

export const useDropdown = (
  itemLength: number,
  onItemSelect?: (index: number) => void
) => {
  const { open, setOpen, buttonRef, panelRef, styles, attributes } = usePanel()
  const menuItemElementsRef = useRef<HTMLLIElement[]>([])
  const [focusIndex, setFocusIndex] = useState<number | null | undefined>()
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
        setFocusIndex(itemLength - 1)

        break
    }
  }

  const handleItemKeyDown = (e: React.KeyboardEvent, index: number) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        setFocusIndex((index + itemLength + 1) % itemLength)

        break
      case 'ArrowUp':
        e.preventDefault()
        setFocusIndex((index + itemLength - 1) % itemLength)

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

        if (onItemSelect) {
          onItemSelect(index)
        } else {
          const link = menuItemElementsRef.current[index].querySelector('a')

          link?.click()
        }

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
    if (focusIndex === undefined) {
      return
    }

    if (focusIndex === null) {
      buttonRef.current?.focus()

      return
    }

    menuItemElementsRef.current[focusIndex].focus()
  }, [open, focusIndex, buttonRef])

  return {
    buttonAttributes: {
      'aria-controls': id,
      'aria-haspopup': true,
      'aria-expanded': open ? true : undefined,
      ref: buttonRef,
      onKeyDown: handleButtonKeyDown,
      onClick: () => {
        setOpen(!open)
      },
    },
    panelAttributes: {
      ref: panelRef,
      style: styles.popper,
      ...attributes.popper,
    },
    listAttributes: {
      id: id,
      role: 'menu',
      hidden: !open,
    },
    itemAttributes: (i: number) => {
      return {
        ref: (instance: HTMLLIElement) => handleMenuItemMount(instance, i),
        onKeyDown: (e: KeyboardEvent) => handleItemKeyDown(e, i),
        tabIndex: -1,
        role: 'menuitem',
      }
    },
  }
}
