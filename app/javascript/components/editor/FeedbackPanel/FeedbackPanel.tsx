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

  const hasFeedback =
    discussion || iteration?.analyzerFeedback || iteration?.representerFeedback

  const automatedFeedbackOpenByDefault = !discussion

  return (
    <Tab.Panel id="feedback" context={TabsContext}>
      <section className="feedback-pane">
        {hasFeedback ? (
          <>
            <AutomatedFeedback
              open={automatedFeedbackOpenByDefault}
              {...AutomatedFeedbackProps}
            />
            <MentoringDiscussion open discussion={discussion} />
          </>
        ) : requestedMentoring ? (
          <PendingMentoringRequest
            mentoringRequestLink={mentoringRequestLink}
          />
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

function PendingMentoringRequest({
  mentoringRequestLink,
}: Pick<FeedbackPanelProps, 'mentoringRequestLink'>): JSX.Element {
  return (
    <div className="flex flex-col">
      <h2 className="text-h4 mb-4">You&apos;ve requested mentoring</h2>
      <p className="text-p-base mb-8">Waiting on a mentor...</p>
      <a className="btn-primary btn-s mr-auto" href={mentoringRequestLink}>
        View your request
      </a>
    </div>
  )
}
