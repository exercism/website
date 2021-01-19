import React, { useEffect, useState, useRef } from 'react'
import { usePopper } from 'react-popper'

export function usePanel() {
  const [open, setOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)
  const panelRef = useRef<HTMLDivElement>(null)
  const { styles, attributes, update: updatePanelPosition } = usePopper(
    buttonRef.current,
    panelRef.current,
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
        panelRef.current?.contains(e.target as Node) ||
        buttonRef.current?.contains(e.target as Node)
      )

      if (clickedOutsideComponent) {
        setOpen(false)
      }
    }

    document.addEventListener('click', handleClick)

    return () => {
      document.removeEventListener('click', handleClick)
    }
  }, [])

  useEffect(() => {
    if (!open || !updatePanelPosition) {
      return
    }

    updatePanelPosition()
  }, [open, updatePanelPosition])

  return {
    open,
    setOpen,
    buttonRef,
    panelRef,
    styles,
    attributes,
  }
}
