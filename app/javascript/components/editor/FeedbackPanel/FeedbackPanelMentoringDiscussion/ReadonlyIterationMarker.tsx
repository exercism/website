// i18n-key-prefix: feedbackPanelMentoringDiscussion.readonlyIterationMarker
// i18n-namespace: components/editor/FeedbackPanel
import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { Iteration } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function ReadonlyIterationMarker({
  idx,
}: Pick<Iteration, 'idx'>): JSX.Element {
  const { t } = useAppTranslation('components/editor/FeedbackPanel')

  return (
    <div className="timeline-entry iteration-entry">
      <div className="timeline-marker">
        <GraphicalIcon icon="iteration" />
      </div>
      <div className="timeline-content">
        <div className="timeline-entry-header">
          <div className="info">
            <strong>
              {t(
                'feedbackPanelMentoringDiscussion.readonlyIterationMarker.iteration',
                {
                  idx,
                }
              )}
            </strong>
          </div>
        </div>
      </div>
    </div>
  )
}
