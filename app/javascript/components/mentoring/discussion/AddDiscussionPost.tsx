import React, { useCallback, useState } from 'react'
import { MentorDiscussion } from '../../types'
import { AddDiscussionPostForm } from './AddDiscussionPostForm'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

// i18n-key-prefix: ......components.mentoring.discussion.addDiscussionPost
// i18n-namespace: discussion
export const AddDiscussionPost = ({
  discussion,
  children,
  onSuccess = () => null,
}: React.PropsWithChildren<{
  discussion: MentorDiscussion
  onSuccess?: () => void
}>): JSX.Element => {
  const { t } = useAppTranslation('discussion-batch')
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
        <Trans i18nKey="components.mentoring.discussion.addDiscussionPost.thisDiscussionHasEnded" />
      </button>
    )
  }
}
