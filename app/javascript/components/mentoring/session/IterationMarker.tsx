import React, { forwardRef } from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { shortFromNow } from '../../../utils/time'
import { Iteration } from '../../types'
import { AutomatedFeedbackSummary } from './AutomatedFeedbackSummary'
import { iterationId } from '../session/useIterationScrolling'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Props = {
  iteration: Iteration
  userIsStudent: boolean
}

export const IterationMarker = forwardRef<HTMLDivElement, Props>(
  ({ iteration, userIsStudent }, ref) => {
    const { t } = useAppTranslation('session-batch-2')
    return (
      <a id={iterationId(iteration)} className="timeline-entry iteration-entry">
        <div className="timeline-marker">
          <GraphicalIcon icon="iteration" />
        </div>
        <div className="timeline-content">
          <div className="timeline-entry-header" ref={ref}>
            <div className="info">
              <strong>
                {t('components.mentoring.session.iterationMarker.iteration', {
                  idx: iteration.idx,
                })}
              </strong>
              {t('components.mentoring.session.iterationMarker.wasSubmitted')}
            </div>
            <time>{shortFromNow(iteration.createdAt)}</time>
          </div>
          {iteration.numActionableAutomatedComments !== 0 ||
          iteration.numEssentialAutomatedComments !== 0 ||
          iteration.numNonActionableAutomatedComments !== 0 ? (
            <AutomatedFeedbackSummary
              userIsStudent={userIsStudent}
              iteration={iteration}
            />
          ) : null}
        </div>
      </a>
    )
  }
)
IterationMarker.displayName = 'IterationMarker'
