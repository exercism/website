import React from 'react'
import { GraphicalIcon, Icon } from '../../common'
import { MentorDiscussion, SolutionMentoringStatus } from '../../types'
import { MentoringComboButton } from '../MentoringComboButton'

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
  return (
    <div className="mentoring">
      <GraphicalIcon
        icon="mentoring-screen"
        className="header-icon"
        category="graphics"
      />
      <h3>Get mentored by a human</h3>
      {isTutorial ? (
        <p>
          You also get the opportunity to be mentored by {trackTitle} experts.
        </p>
      ) : (
        <>
          <p>
            On average, students iterate a further 3.5 times when mentored on a
            solution.
          </p>
          <MentoringComboButton
            mentoringStatus={mentoringStatus}
            discussions={discussions}
            links={links}
          />
          <a href={links.learnMoreAboutMentoringArticle} className="learn-more">
            Learn more
            <Icon icon="external-link" alt="Opens in new tab" />
          </a>
        </>
      )}
    </div>
  )
}
