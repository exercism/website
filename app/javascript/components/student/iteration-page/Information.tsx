import React from 'react'
import { GraphicalIcon } from '../../common'
import { Iteration, IterationStatus } from '../../types'
import { Exercise, Track, Links } from '../IterationPage'
import { RepresenterFeedback } from './RepresenterFeedback'
import { AnalyzerFeedback } from './AnalyzerFeedback'

export const Information = ({
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
    case IterationStatus.TESTING:
    case IterationStatus.ANALYZING:
      return (
        <div className="automated-feedback-pending">
          <GraphicalIcon icon="spinner" />
          <h3>We&apos;re analysing your code for suggestions</h3>
          <p>This usually takes 10-30 seconds.</p>
        </div>
      )
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
