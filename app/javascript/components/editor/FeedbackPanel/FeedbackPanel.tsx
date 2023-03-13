import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from '../../Editor'
import { Iteration, MentorDiscussion, Exercise, Track } from '../../types'
import { AutomatedFeedback } from './FeedbackPanelAutomatedFeedback'
import { MentoringDiscussion } from './FeedbackPanelMentoringDiscussion'
import { RequestMentoring } from './FeedbackPanelRequestMentoring'

export type FeedbackPanelProps = {
  iteration?: Pick<Iteration, 'analyzerFeedback' | 'representerFeedback'>
  exercise: Pick<Exercise, 'title'>
  track: Pick<Track, 'title' | 'iconUrl'>
  automatedFeedbackInfoLink: string
  mentorDiscussionsLink: string
  discussion?: MentorDiscussion
}
export const FeedbackPanel = ({
  iteration,
  exercise,
  track,
  automatedFeedbackInfoLink,
  mentorDiscussionsLink,
  discussion,
}: FeedbackPanelProps): JSX.Element => {
  const AutomatedFeedbackProps = { iteration, track, automatedFeedbackInfoLink }

  const hasFeedback =
    discussion || iteration?.analyzerFeedback || iteration?.representerFeedback

  const mentoringDiscussionOpenByDefault =
    discussion &&
    !(iteration?.analyzerFeedback && iteration?.representerFeedback)

  return (
    <Tab.Panel id="feedback" context={TabsContext}>
      <section className="feedback-pane">
        {hasFeedback ? (
          <>
            <AutomatedFeedback {...AutomatedFeedbackProps} />
            <MentoringDiscussion
              open={mentoringDiscussionOpenByDefault}
              discussion={discussion}
            />
          </>
        ) : (
          <RequestMentoring
            track={track}
            exercise={exercise}
            mentorDiscussionsLink={mentorDiscussionsLink}
          />
        )}
      </section>
    </Tab.Panel>
  )
}
