import React, { useCallback } from 'react'
import { usePanel } from '../../../hooks/use-panel'
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
    componentRef,
    styles,
    attributes,
  } = usePanel()

  const handleSuccess = useCallback(() => setOpen(false), [setOpen])

  return (
    <section className="comment-section" ref={componentRef}>
      {/* TODO: Don't know why this doesn't work */}
      {/* {open ? null : ( */}
      <button
        className="faux-input"
        ref={buttonRef}
        onClick={() => {
          setOpen(true)
        }}
        type="button"
      >
        Add a comment
      </button>
      {/*)}*/}
      {open ? (
        <DiscussionPostForm
          onSuccess={handleSuccess}
          endpoint={endpoint}
          method="POST"
          contextId={contextId}
        />
      ) : null}
    </section>
  )
}
