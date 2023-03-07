import React from 'react'
import { QueryStatus } from 'react-query'
import { GraphicalIcon, Tab } from '../common'
import { TabsContext } from '../Editor'
import { DiscussionPostList } from '../mentoring/discussion/DiscussionPostList'
import { AnalyzerFeedback } from '../student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '../student/iterations-list/RepresenterFeedback'
import { Links } from '../student/MentoringDropdown'
import { Mentor } from '../student/MentoringSession'
import { Iteration, MentorDiscussion, Track } from '../types'

// TODO: pass down these, add types

type FeedbackPanelProps = {
  iteration: Pick<Iteration, 'analyzerFeedback' | 'representerFeedback'>
  track: Pick<Track, 'title' | 'iconUrl'>
  automatedFeedbackInfoLink: string
  discussion: MentorDiscussion
  mentor: Mentor
  userHandle: string
  iterations: readonly Iteration[]
  onIterationScroll: (iteration: Iteration) => void
  links: Links
  status: QueryStatus
}
export const FeedbackPanel = ({
  iteration,
  track,
  automatedFeedbackInfoLink,
  iterations,
  discussion,
  userHandle,
  status,
  onIterationScroll,
}: FeedbackPanelProps): JSX.Element => {
  return (
    <Tab.Panel id="feedback" context={TabsContext}>
      <section className="feedback-pane">
        <FeedbackDetail summary="Automated Feedback">
          {iteration.representerFeedback ? (
            <RepresenterFeedback {...iteration.representerFeedback} />
          ) : null}
          {iteration.analyzerFeedback ? (
            <AnalyzerFeedback
              {...iteration.analyzerFeedback}
              track={track}
              automatedFeedbackInfoLink={automatedFeedbackInfoLink}
            />
          ) : null}
        </FeedbackDetail>
        <FeedbackDetail summary="Mentoring Discussion">
          <DiscussionPostList
            // This should be the last iteration
            iterations={iterations}
            userIsStudent={true}
            discussionUuid={discussion.uuid}
            userHandle={userHandle}
            onIterationScroll={onIterationScroll}
            status={status}
          />
        </FeedbackDetail>
      </section>
    </Tab.Panel>
  )
}

function FeedbackDetail({
  summary,
  children,
}: {
  summary: string
  children: React.ReactNode
}): JSX.Element {
  return (
    <details className="c-details feedback">
      <summary className="--summary">
        <div className="--summary-inner">
          <span className="summary-title">{summary}</span>
          <span className="--closed-icon">
            <GraphicalIcon icon="chevron-right" />
          </span>
          <span className="--open-icon">
            <GraphicalIcon icon="chevron-down" />
          </span>
        </div>
      </summary>
      {children}
    </details>
  )
}
