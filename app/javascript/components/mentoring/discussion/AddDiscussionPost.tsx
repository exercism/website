import React, { useCallback, useState } from 'react'
import { MentorDiscussion } from '../../types'
import { AddDiscussionPostForm } from './AddDiscussionPostForm'

export const AddDiscussionPost = ({
  discussion,
  onSuccess = () => null,
}: {
  discussion: MentorDiscussion
  onSuccess?: () => void
}): JSX.Element => {
  const [stillPosting, setStillPosting] = useState(!discussion.isFinished)

  const handleSuccess = useCallback(() => {
    onSuccess()
  }, [onSuccess])

  const handleContinue = useCallback(() => {
    setStillPosting(true)
  }, [])

  if (stillPosting) {
    return (
      <>
        <AddDiscussionPostForm
          discussion={discussion}
          onSuccess={handleSuccess}
        />

        <div className="note">
          Check out our {/* TODO: (required) */}
          <a href="#">mentoring docs</a> and be the best mentor you can be.
        </div>
      </>
    )
  } else {
    return (
      <button
        onClick={handleContinue}
        className="continuation-btn"
        type="button"
      >
        <strong>This discussion has ended.</strong> Have more to say? You can{' '}
        <em>still post</em>.
      </button>
    )
  }
}
