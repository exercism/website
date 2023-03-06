import React from 'react'
import { GraphicalIcon, Tab } from '../common'
import { TabsContext } from '../Editor'
import { AnalyzerFeedback } from '../student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '../student/iterations-list/RepresenterFeedback'
import { Iteration, Track } from '../types'

// TODO: pass down these, add types

type FeedbackPanelProps = {
  iteration: Pick<Iteration, 'analyzerFeedback' | 'representerFeedback'>
  track: Pick<Track, 'title' | 'iconUrl'>
  automatedFeedbackInfoLink: string
}
export const FeedbackPanel = ({
  iteration,
  track,
  automatedFeedbackInfoLink,
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
        <FeedbackDetail summary="Mentoring">lmao</FeedbackDetail>
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
