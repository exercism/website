import { useEffect, useState, useCallback } from 'react'
import { usePopper } from 'react-popper'

export function usePanel(options?: any) {
  const [open, setOpen] = useState(false)
  const [buttonElement, setButtonElement] = useState<HTMLElement | null>(null)
  const [panelElement, setPanelElement] = useState<HTMLDivElement | null>(null)
  const { styles, attributes, update } = usePopper(
    buttonElement,
    panelElement,
    options || {
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

  const handleInnerClick = useCallback((e) => {
    e.stopPropagation()
    e.nativeEvent.stopImmediatePropagation()
  }, [])

  const handleMouseDown = useCallback(() => {
    if (!open) {
      return
    }

    setOpen(false)
  }, [open])

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
      onMouseDown: handleInnerClick,
    },
    panelAttributes: {
      ref: setPanelElement,
      style: styles.popper,
      ...attributes.popper,
      onMouseDown: handleInnerClick,
    },
  }
}
