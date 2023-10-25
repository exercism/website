import { useEffect, useState, useCallback } from 'react'
import { usePopper } from 'react-popper'

export function usePanel(options?: any) {
  let modifiers = [
    {
      name: 'offset',
      options: {
        offset: [0, 2],
      },
    },
  ]

  const [open, setOpen] = useState(false)
  const [buttonElement, setButtonElement] = useState<HTMLElement | null>(null)
  const [panelElement, setPanelElement] = useState<HTMLDivElement | null>(null)
  const { styles, attributes, update } = usePopper(
    buttonElement,
    panelElement,
    options || {
      placement: options?.placement || 'bottom-end',
      modifiers: modifiers,
    }
  )

  const handleMouseDown = useCallback(
    (e) => {
      if (
        buttonElement?.contains(e.target) ||
        panelElement?.contains(e.target)
      ) {
        return
      }

      if (!open) {
        return
      }

      setOpen(false)
    },
    [buttonElement, open, panelElement]
  )

  useEffect(() => {
    document.addEventListener('mousedown', handleMouseDown)

    return () => {
      document.removeEventListener('mousedown', handleMouseDown)
    }
  }, [handleMouseDown])

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
    buttonAttributes: {
      ref: setButtonElement,
    },
    panelAttributes: {
      ref: setPanelElement,
      style: styles.popper,
      ...attributes.popper,
    },
  }
}
