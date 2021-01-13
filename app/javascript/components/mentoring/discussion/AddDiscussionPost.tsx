import React, { useCallback, useState } from 'react'
import { DiscussionPostForm } from './DiscussionPostForm'

export const AddDiscussionPost = ({
  endpoint,
  contextId,
  onSuccess = () => {},
}: {
  endpoint: string
  contextId: string
  onSuccess?: () => void
}): JSX.Element => {
  const [open, setOpen] = useState(false)
  const [value, setValue] = useState('')

  const handleSuccess = useCallback(() => {
    setOpen(false)
    setValue('')
    onSuccess()
  }, [onSuccess])

  return (
    <section className="comment-section">
      {open ? (
        <div>
          <DiscussionPostForm
            onSuccess={handleSuccess}
            endpoint={endpoint}
            method="POST"
            contextId={contextId}
            value={value}
          />
          <button
            type="button"
            onClick={() => {
              setOpen(false)
            }}
          >
            Cancel
          </button>
        </div>
      ) : (
        <button
          className="faux-input"
          onClick={() => {
            setOpen(true)
          }}
          type="button"
        >
          Add a comment
        </button>
      )}
    </section>
  )
}
