import React, { useEffect, useState } from 'react'
import { usePopper } from 'react-popper'

export function usePanel() {
  const [open, setOpen] = useState(false)
  const [buttonElement, setButtonElement] = useState<HTMLButtonElement | null>(
    null
  )
  const [panelElement, setPanelElement] = useState<HTMLDivElement | null>(null)
  const { styles, attributes, update } = usePopper(
    buttonElement,
    panelElement,
    {
      placement: 'bottom-end',
      modifiers: [
        {
          name: 'offset',
          options: {
            offset: [0, 2],
          },
        },
      ],
    }
  )

  useEffect(() => {
    const handleClick = (e: MouseEvent) => {
      const clickedOutsideComponent = !(
        panelElement?.contains(e.target as Node) ||
        buttonElement?.contains(e.target as Node)
      )

      if (clickedOutsideComponent) {
        setOpen(false)
      }
    }

    document.addEventListener('click', handleClick)

    return () => {
      document.removeEventListener('click', handleClick)
    }
  }, [buttonElement, panelElement])

  useEffect(() => {
    if (!update) {
      return
    }

    if (open) {
      update()
    }
  }, [update, open])

  return {
    open,
    setOpen,
    buttonElement,
    setButtonElement,
    panelElement,
    setPanelElement,
    styles,
    attributes,
  }
}
