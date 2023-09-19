import React, { useState } from 'react'
import { FinishMentorDiscussionModal } from '../../modals/student/FinishMentorDiscussionModal'
import { ConfirmFinishMentorDiscussionModal } from '../../modals/student/ConfirmFinishMentorDiscussionModal'
import {
  MentorDiscussion,
  MentoringSessionDonation,
  MentoringSessionLinks,
} from '../../types'

type Status = 'initialized' | 'confirming' | 'finishing'

export const FinishButton = ({
  discussion,
  donation,
  className,
  children,
  links,
}: React.PropsWithChildren<{
  className: string
  discussion: MentorDiscussion
  donation: MentoringSessionDonation
  links: MentoringSessionLinks
}>): JSX.Element => {
  const [status, setStatus] = useState<Status>('initialized')

  return (
    <React.Fragment>
      <button
        type="button"
        className={className}
        onClick={() => {
          setStatus('confirming')
        }}
      >
        {children}
      </button>
      <ConfirmFinishMentorDiscussionModal
        open={status === 'confirming'}
        onConfirm={() => {
          setStatus('finishing')
        }}
        onCancel={() => {
          setStatus('initialized')
        }}
      />
      <FinishMentorDiscussionModal
        discussion={discussion}
        links={links}
        open={status === 'finishing'}
        onClose={() => {
          setStatus('initialized')
        }}
        onCancel={() => {
          setStatus('initialized')
        }}
        donation={donation}
      />
    </React.Fragment>
  )
}
