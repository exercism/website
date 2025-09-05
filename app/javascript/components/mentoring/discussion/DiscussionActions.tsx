import React, { useCallback } from 'react'
import { MarkAsNothingToDoButton } from './MarkAsNothingToDoButton'
import { FinishButton } from './FinishButton'
import { GraphicalIcon } from '../../common'
import { SessionProps } from '../Session'
import { MentorDiscussion as Discussion } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

// i18n-key-prefix: ......components.mentoring.discussion.discussionActions
// i18n-namespace: discussion
export const DiscussionActions = ({
  status,
  links,
  session,
  setSession,
  isFinished,
}: Discussion & {
  session: SessionProps
  setSession: (session: SessionProps) => void
}): JSX.Element => {
  const { t } = useAppTranslation()
  const handleSuccess = useCallback(
    (discussion) => {
      const { student, ...discussionProps } = discussion

      setSession({
        ...session,
        discussion: discussionProps,
        student: student,
      })
    },
    [setSession, session]
  )

  return (
    <>
      {status === 'awaiting_mentor' ? (
        <MarkAsNothingToDoButton endpoint={links.markAsNothingToDo} />
      ) : null}

      {isFinished ? (
        <div className="finished">
          <GraphicalIcon icon="completed-check-circle" />
          {t('components.mentoring.discussion.discussionActions.ended')}
        </div>
      ) : links.finish ? (
        <FinishButton endpoint={links.finish} onSuccess={handleSuccess} />
      ) : null}
    </>
  )
}
