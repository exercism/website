import React from 'react'
import { GraphicalIcon, Tab } from '@/components/common'
import { TabsContext } from '../../Editor'
import { Iteration, MentorDiscussion, Track } from '../../types'
import { AutomatedFeedback } from './FeedbackPanelAutomatedFeedback'
import { MentoringDiscussion } from './FeedbackPanelMentoringDiscussion'

export type FeedbackPanelProps = {
  iteration?: Pick<Iteration, 'analyzerFeedback' | 'representerFeedback'>
  track: Pick<Track, 'title' | 'iconUrl'>
  automatedFeedbackInfoLink: string
  mentorDiscussionsLink: string
  discussion?: MentorDiscussion
}
export const FeedbackPanel = ({
  iteration,
  track,
  automatedFeedbackInfoLink,
  mentorDiscussionsLink,
  discussion,
}: FeedbackPanelProps): JSX.Element => {
  const AutomatedFeedbackProps = { iteration, track, automatedFeedbackInfoLink }

  const HasFeedback =
    discussion || iteration?.analyzerFeedback || iteration?.representerFeedback

  return (
    <Tab.Panel id="feedback" context={TabsContext}>
      <section className="feedback-pane">
        {HasFeedback ? (
          <>
            <AutomatedFeedback {...AutomatedFeedbackProps} />
            <MentoringDiscussion discussion={discussion} />
          </>
        ) : (
          <RequestMentoring mentorDiscussionsLink={mentorDiscussionsLink} />
        )}
      </section>
    </Tab.Panel>
  )
}

function RequestMentoring({
  mentorDiscussionsLink,
}: Pick<FeedbackPanelProps, 'mentorDiscussionsLink'>): JSX.Element {
  return (
    <section className="run-tests-prompt">
      <GraphicalIcon icon="mentoring" className="filter-textColor6" />
      <h2>
        Please&nbsp;
        <a className="underline" href={mentorDiscussionsLink}>
          request mentoring
        </a>
        &nbsp;to get feedback.
      </h2>
    </section>
  )
}
