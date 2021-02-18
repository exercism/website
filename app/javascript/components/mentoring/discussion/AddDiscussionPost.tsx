import React, { useCallback, useState } from 'react'
import { DiscussionPostForm } from './DiscussionPostForm'

export const AddDiscussionPost = ({
  isFinished,
  endpoint,
  contextId,
  onSuccess = () => {},
}: {
  isFinished: boolean
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

  if (open) {
    return (
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
    )
  } else {
    if (isFinished) {
      return (
        <div>
          This discussion has ended. Have more to say? You can
          <button
            onClick={() => {
              setOpen(true)
            }}
            type="button"
          >
            still post.
          </button>
        </div>
      )
    } else {
      return (
        <button
          className="faux-input"
          onClick={() => {
            setOpen(true)
          }}
          type="button"
        >
          Add a comment
        </button>
      )
    }
  }
}
