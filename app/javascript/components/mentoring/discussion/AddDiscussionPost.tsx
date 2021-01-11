import React, { useCallback, useState } from 'react'
import { DiscussionPostForm } from './DiscussionPostForm'

export const AddDiscussionPost = ({
  endpoint,
  contextId,
}: {
  endpoint: string
  contextId: string
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  const handleSuccess = useCallback(() => setOpen(false), [setOpen])

  return (
    <section className="comment-section">
      <button
        className="faux-input"
        onClick={() => {
          setOpen(true)
        }}
        type="button"
      >
        Add a comment
      </button>
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
