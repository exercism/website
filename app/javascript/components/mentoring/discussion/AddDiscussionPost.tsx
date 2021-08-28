import React, { useCallback, useState } from 'react'
import { MentorDiscussion } from '../../types'
import { AddDiscussionPostForm } from './AddDiscussionPostForm'

export const AddDiscussionPost = ({
  discussion,
  children,
  onSuccess = () => null,
}: React.PropsWithChildren<{
  discussion: MentorDiscussion
  onSuccess?: () => void
}>): JSX.Element => {
  const [stillPosting, setStillPosting] = useState(!discussion.isFinished)

  const handleSuccess = useCallback(() => {
    onSuccess()
  }, [onSuccess])

  const handleContinue = useCallback(() => {
    setStillPosting(true)
  }, [])

  if (stillPosting) {
    return (
      <React.Fragment>
        <AddDiscussionPostForm
          discussion={discussion}
          onSuccess={handleSuccess}
        />
        {children}
      </React.Fragment>
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
