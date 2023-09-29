import React, { useState } from 'react'
import { FinishMentorDiscussionModal } from '../../modals/student/FinishMentorDiscussionModal'
import { ConfirmFinishMentorDiscussionModal } from '../../modals/student/ConfirmFinishMentorDiscussionModal'
import { MentorDiscussion, MentoringSessionDonation } from '../../types'
import { DiscussionActionsLinks } from './DiscussionActions'

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
  links: DiscussionActionsLinks
}>): JSX.Element => {
  const [status, setStatus] = useState<Status>('initialized')

  const timedOut =
    discussion.finishedBy &&
    ['mentor_timed_out', 'student_timed_out'].includes(discussion.finishedBy)

  return (
    <React.Fragment>
      <button
        type="button"
        className={className}
        onClick={() => {
          timedOut ? setStatus('finishing') : setStatus('confirming')
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
