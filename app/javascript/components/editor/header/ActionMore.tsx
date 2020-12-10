import React, { useCallback } from 'react'
import { Icon } from '../../common/Icon'
import { usePanel } from './usePanel'

export const ActionMore = ({
  onRevert,
  isRevertDisabled,
}: {
  onRevert: () => void
  isRevertDisabled: boolean
}): JSX.Element => {
  const {
    open,
    setOpen,
    buttonRef,
    panelRef,
    componentRef,
    styles,
    attributes,
  } = usePanel()

  const handleRevert = useCallback(() => {
    onRevert()

    setOpen(false)
  }, [onRevert, setOpen])

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
