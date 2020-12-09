import React, { useEffect, useState, useRef, useCallback } from 'react'
import { usePopper } from 'react-popper'
import { Icon } from '../../common/Icon'

export const ActionMore = ({
  onRevert,
  isRevertDisabled,
}: {
  onRevert: () => void
  isRevertDisabled: boolean
}): JSX.Element => {
  const [open, setOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)
  const panelRef = useRef<HTMLDivElement>(null)
  const componentRef = useRef<HTMLDivElement>(null)
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
  const handleRevert = useCallback(() => {
    onRevert()
  }, [onRevert])

  useEffect(() => {
    const handleClick = (e: MouseEvent) => {
      const clickedOutsideComponent = !componentRef.current?.contains(
        e.target as Node
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

  return (
    <div ref={componentRef}>
      <button
        ref={buttonRef}
        className="more-btn"
        onClick={() => {
          setOpen(!open)
        }}
      >
        <Icon icon="more-horizontal" alt="Open more options" />
      </button>
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        {open ? (
          <div>
            <button
              onClick={handleRevert}
              type="button"
              disabled={isRevertDisabled}
            >
              Revert to last iteration submission
            </button>
          </div>
        ) : null}
      </div>
    </div>
  )
}
