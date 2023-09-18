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
    <GetHelpAccordionSkeleton title="Hints and Tips" className="hints">
      <>
        <div className="pt-8 flex flex-col gap-2">
          <p className="text-p-base text-color-2 mb-8">
            Stuck? These hints will give you nudges to the right direction to
            get you unblocked. Use them wisely though - remember that wrestling
            with a problem is where the learning occurs!
          </p>
          <p className="text-p-base text-color-2">
            Click a heading to expand the hints:
          </p>
        </div>
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
            heading={`Task ${idx + 1}. ${task.title}`}
            expanded={false}
            collapsable={true}
          />
        ))}
      </>
    </GetHelpAccordionSkeleton>
  )
}
