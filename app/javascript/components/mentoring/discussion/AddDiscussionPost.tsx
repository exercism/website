import React, { useCallback, useState } from 'react'
import { DiscussionPostForm } from './DiscussionPostForm'
import { GraphicalIcon } from '../../common/GraphicalIcon'

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
    return (
      /* TODO: We need to toggle here between two designs
          based on whether the discussion has finished or not.
          The both have the same functionality, but different styling */

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
