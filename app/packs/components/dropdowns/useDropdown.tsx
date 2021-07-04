import React, {
  useState,
  useEffect,
  useMemo,
  useRef,
  KeyboardEvent,
} from 'react'
import { usePanel } from '../../hooks/use-panel'
import { v4 as uuidv4 } from 'uuid'

export type DropdownAttributes = {
  buttonAttributes: ButtonAttributes
  panelAttributes: any
  itemAttributes: (index: number) => ItemAttributes
  listAttributes: ListAttributes
  open: boolean
  setOpen: (open: false) => void
}

type ButtonAttributes = {
  'aria-controls': string
  'aria-haspopup': true
  'aria-expanded': boolean | undefined
  ref: (element: HTMLButtonElement) => void
  onKeyDown: (e: KeyboardEvent) => void
  onClick: () => void
}

type ItemAttributes = {
  ref: (instance: HTMLLIElement) => void
  onKeyDown: (e: KeyboardEvent) => void
  tabIndex: -1
  role: 'menuitem'
}

type ListAttributes = {
  id: string
  role: 'menu'
  hidden: boolean
}

export const useDropdown = (
  itemLength: number,
  onItemSelect?: (index: number) => void,
  panelOptions?: any
): DropdownAttributes => {
  const {
    open,
    setOpen,
    buttonElement,
    buttonAttributes,
    panelAttributes,
  } = usePanel(panelOptions || {})
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

        if (onItemSelect) {
          onItemSelect(index)
        } else {
          const link = menuItemElementsRef.current[index].querySelector('a')
          const button = menuItemElementsRef.current[index].querySelector(
            'button'
          )

          setOpen(false)
          link?.click()
          button?.click()
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
      buttonElement?.focus()

      return
    }

    menuItemElementsRef.current[focusIndex].focus()
  }, [open, focusIndex, buttonElement])

  return {
    buttonAttributes: {
      'aria-controls': id,
      'aria-haspopup': true,
      'aria-expanded': open ? true : undefined,
      ...buttonAttributes,
      onClick: () => setOpen(!open),
      onKeyDown: handleButtonKeyDown,
    },
    panelAttributes: panelAttributes,
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
    open,
    setOpen,
  }
}
