import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GetHelpPanelProps } from '../GetHelpPanel'
import { GetHelpAccordionSkeleton } from './GetHelpAccordionSkeleton'
import { Hints } from './GetHelpPanelHints'

export function GetHelpPanelHints({
  assignment,
}: Pick<GetHelpPanelProps, 'assignment'>): JSX.Element | null {
  if (assignment.generalHints.length === 0 && assignment.tasks.length === 0) {
    return null
  }

  return (
    <details className="c-details">
      <summary className="flex items-center justify-between">
        <span className="text-h4">Hints and Tips</span>
        <span className="--closed-icon">
          <GraphicalIcon icon="chevron-right" height={12} width={12} />
        </span>
        <span className="--open-icon">
          <GraphicalIcon icon="chevron-down" height={12} width={12} />
        </span>
      </summary>
      <GetHelpAccordionSkeleton>
        <Hints
          hints={assignment.generalHints}
          heading="General"
          expanded={assignment.tasks.length === 0}
          collapsable={assignment.tasks.length > 0}
        />
        {assignment.tasks.map((task, idx) => (
          <Hints
            key={idx}
            hints={task.hints}
            heading={`${idx + 1}. ${task.title}`}
            expanded={false}
            collapsable={true}
          />
        ))}
      </GetHelpAccordionSkeleton>
    </details>
  )
}
