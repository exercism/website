import React from 'react'
import { GetHelpPanelProps } from '../GetHelpPanel'
import { GetHelpAccordionSkeleton } from './GetHelpAccordionSkeleton'
import { Hints } from './Hints'

export function GetHelpPanelHints({
  assignment,
}: Pick<GetHelpPanelProps, 'assignment'>): JSX.Element | null {
  if (assignment.generalHints.length === 0 && assignment.tasks.length === 0) {
    return null
  }

  return (
    <GetHelpAccordionSkeleton title="Hints and Tips">
      <>
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
      </>
    </GetHelpAccordionSkeleton>
  )
}
