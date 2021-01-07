import React, { useCallback } from 'react'
import { usePanel } from '../../../hooks/use-panel'
import { DiscussionPostForm } from './DiscussionPostForm'

export const EditDiscussionPost = ({
  value,
  endpoint,
  contextId,
}: {
  value: string
  endpoint: string
  contextId: string
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

  const handleSuccess = useCallback(() => setOpen(false), [setOpen])

  return (
    <div ref={componentRef}>
      <button
        ref={buttonRef}
        onClick={() => {
          setOpen(!open)
        }}
        type="button"
      >
        Edit
      </button>
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        {open ? (
          <DiscussionPostForm
            onSuccess={handleSuccess}
            endpoint={endpoint}
            method="PATCH"
            contextId={contextId}
            value={value}
          />
        ) : null}
      </div>
    </div>
  )
}
