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
      <>
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
        {/* TODO: DRY up the duplication of this */}
        <div className="note">
          Check out our {/* TODO */}
          <a href="#">mentoring docs</a> and be the best mentor you can be.
        </div>
      </>
    )
  } else {
    if (isFinished) {
      return (
        <button
          onClick={() => {
            setOpen(true)
          }}
          className="continuation-btn"
          type="button"
        >
          <strong>This discussion has ended.</strong> Have more to say? You can{' '}
          <em>still post</em>.
        </button>
      )
    } else {
      return (
        <>
          <button
            className="faux-input"
            onClick={() => {
              setOpen(true)
            }}
            type="button"
          >
            Add a comment
          </button>
          {/* TODO: DRY up the duplication of this */}
          <div className="note">
            Check out our {/* TODO */}
            <a href="#">mentoring docs</a> and be the best mentor you can be.
          </div>
        </>
      )
    }
  }
}
