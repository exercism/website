import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../Editor'
import { Iteration, MentorDiscussion, Exercise, Track } from '../../types'
import { AutomatedFeedback } from './FeedbackPanelAutomatedFeedback'
import { MentoringDiscussion } from './FeedbackPanelMentoringDiscussion/FeedbackPanelMentoringDiscussion'
import { RequestMentoring } from './FeedbackPanelRequestMentoring'

export type FeedbackPanelProps = {
  iteration?: Pick<Iteration, 'analyzerFeedback' | 'representerFeedback'>
  exercise: Pick<Exercise, 'title'>
  track: Pick<Track, 'title' | 'iconUrl'>
  mentoringRequestLink: string
  automatedFeedbackInfoLink: string
  mentorDiscussionsLink: string
  discussion?: MentorDiscussion
  requestedMentoring: boolean
}
export const FeedbackPanel = ({
  iteration,
  exercise,
  track,
  automatedFeedbackInfoLink,
  mentorDiscussionsLink,
  mentoringRequestLink,
  requestedMentoring,
  discussion,
}: FeedbackPanelProps): JSX.Element => {
  const AutomatedFeedbackProps = { iteration, track, automatedFeedbackInfoLink }
  const MentoringDiscussionProps = {
    mentoringRequestLink,
    discussion,
    requestedMentoring,
  }
  const RequestMentoringProps = { track, exercise, mentorDiscussionsLink }

  const hasFeedback =
    discussion ||
    iteration?.analyzerFeedback ||
    iteration?.representerFeedback ||
    requestedMentoring

  const automatedFeedbackOpenByDefault = !discussion

  return (
    <Tab.Panel id="feedback" context={TabsContext}>
      <section className="feedback-pane">
        {hasFeedback ? (
          <>
            <MentoringDiscussion open {...MentoringDiscussionProps} />
            <AutomatedFeedback
              open={automatedFeedbackOpenByDefault}
              {...AutomatedFeedbackProps}
            />
          </>
        ) : (
          <RequestMentoring {...RequestMentoringProps} />
        )}
      </section>
    </Tab.Panel>
  )
}
