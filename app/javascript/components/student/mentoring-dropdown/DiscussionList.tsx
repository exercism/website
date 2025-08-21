import React from 'react'
import { MentorDiscussion } from '../../types'
import { MentorDiscussionSummary } from '../../common/MentorDiscussionSummary'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const DiscussionList = ({
  discussions,
}: {
  discussions: readonly MentorDiscussion[]
}): JSX.Element => {
  const { t } = useAppTranslation('components/student/mentoring-dropdown')
  if (discussions.length === 0) {
    return (
      <div className="no-discussions">
        <h3>{t('discussionList.codeReviewSessions')}</h3>
        <p>{t('discussionList.appearHereOnceStarted')}</p>
      </div>
    )
  }

  return (
    <div className="discussions">
      <h3>{t('discussionList.mentoringDiscussions')}</h3>
      {discussions.map((discussion) => (
        <MentorDiscussionSummary key={discussion.uuid} {...discussion} />
      ))}
    </div>
  )
}
