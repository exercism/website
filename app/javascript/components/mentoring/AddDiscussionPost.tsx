import React, { useCallback } from 'react'
import { usePanel } from '../../hooks/use-panel'
import { DiscussionPostForm } from './DiscussionPostForm'

export const AddDiscussionPost = ({
  endpoint,
  contextId,
}: {
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
        Add a comment
      </button>
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        {open ? (
          <DiscussionPostForm
            onSuccess={handleSuccess}
            endpoint={endpoint}
            method="POST"
            contextId={contextId}
          />
        ) : null}
      </div>
    </div>
  )
}
