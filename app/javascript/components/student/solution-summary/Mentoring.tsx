import React from 'react'
import { GraphicalIcon, Icon } from '../../common'
import { MentorDiscussion, SolutionMentoringStatus } from '../../types'
import { MentoringComboButton } from '../MentoringComboButton'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  learnMoreAboutMentoringArticle: string
  shareMentoring: string
  requestMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

export const Mentoring = ({
  mentoringStatus,
  discussions,
  links,
  isTutorial,
  trackTitle,
}: {
  mentoringStatus: SolutionMentoringStatus
  discussions: readonly MentorDiscussion[]
  links: Links
  isTutorial: boolean
  trackTitle: string
}): JSX.Element => {
  const { t } = useAppTranslation('components/student/solution-summary')
  return (
    <div className="mentoring">
      <GraphicalIcon
        icon="mentoring-screen"
        className="header-icon"
        category="graphics"
      />
      <h3>{t('mentoring.getMentoredByAHuman')}</h3>
      {isTutorial ? (
        <p>
          {t('mentoring.youAlsoGetTheOpportunityToBeMentored', { trackTitle })}
        </p>
      ) : (
        <>
          <p>{t('mentoring.onAverageStudentsIterate')}</p>
          <MentoringComboButton
            mentoringStatus={mentoringStatus}
            discussions={discussions}
            links={links}
          />
          <a href={links.learnMoreAboutMentoringArticle} className="learn-more">
            {t('mentoring.learnMore')}
            <Icon icon="external-link" alt="Opens in new tab" />
          </a>
        </>
      )}
    </div>
  )
}
