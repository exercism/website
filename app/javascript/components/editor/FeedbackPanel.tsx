import React from 'react'
import { GraphicalIcon, Tab } from '../common'
import { TabsContext } from '../Editor'
import { AnalyzerFeedback } from '../student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '../student/iterations-list/RepresenterFeedback'

// TODO: pass down these, add types
export const FeedbackPanel = ({ iteration, track, links }): JSX.Element => {
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
              automatedFeedbackInfoLink={links.automatedFeedbackInfo}
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
