import React from 'react'
import { GraphicalIcon } from '../../common'
import { Iteration, IterationStatus } from '../../types'
import { Exercise, Track, Links } from '../IterationsList'
import { RepresenterFeedback } from './RepresenterFeedback'
import { AnalyzerFeedback } from './AnalyzerFeedback'

export const AnalysisInformation = ({
  iteration,
  exercise,
  track,
  links,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
}): JSX.Element | null => {
  switch (iteration.status) {
    case IterationStatus.DELETED:
    case IterationStatus.TESTING:
    case IterationStatus.ANALYZING:
      return (
        <div className="automated-feedback-pending">
          <GraphicalIcon icon="spinner" className="animate-spin-slow" />
          <h3>We&apos;re analysing your code for suggestions</h3>
          <p>This usually takes 10-30 seconds.</p>
        </div>
      )
    case IterationStatus.UNTESTED:
    case IterationStatus.NO_AUTOMATED_FEEDBACK:
      return (
        <div className="automated-feedback-absent">
          <GraphicalIcon icon="mentoring" category="graphics" />
          <h3>No auto suggestions? Try human mentoring.</h3>
          <p>
            Get real 1-to-1 human mentoring on the {exercise.title} exercise and
            start writing better {track.title}.
          </p>
          <a href={links.getMentoring} className="btn-secondary btn-m">
            Get mentoring
          </a>
        </div>
      )
    case IterationStatus.TESTS_FAILED:
      return (
        <div className="automated-feedback-absent">
          <GraphicalIcon icon="tests-failed" category="graphics" />
          <h3>Beep boop bob a hop, could not compute…</h3>
          <p>
            In order for our systems to analyze your code, the tests must be
            passing.
          </p>
          <div className="upsell">
            Interested in improving Exercism&apos;s automated tooling?{' '}
            <a href={links.toolingHelp}>We need your help</a>.
          </div>
        </div>
      )
    default: {
      return (
        <React.Fragment>
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
        </React.Fragment>
      )
    }
  }
}
