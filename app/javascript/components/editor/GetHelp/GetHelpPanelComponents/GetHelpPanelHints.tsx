import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GetHelpPanelProps } from '../GetHelpPanel'

export function GetHelpPanelHints({
  assignment,
}: Pick<GetHelpPanelProps, 'assignment'>): JSX.Element | null {
  if (assignment.generalHints.length === 0 && assignment.tasks.length === 0) {
    return null
  }

  return (
    <div className="flex flex-col">
      <header className='flex items-center gap-12 mb-24"'>
        <GraphicalIcon icon="hints" category="graphics" />
        <h2>Hints and Tips</h2>
      </header>
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
    </div>
  )
}

const Hints = ({
  heading,
  hints,
  expanded,
  collapsable,
}: {
  heading: string
  hints: string[] | undefined
  expanded: boolean
  collapsable: boolean
}) => {
  if (hints === undefined || hints.length === 0) {
    return null
  }

  return (
    <details className="c-details" open={expanded}>
      <summary className="--summary">
        <div className="--summary-inner">
          {heading}
          {collapsable ? (
            <>
              <GraphicalIcon icon="plus-circle" className="--closed-icon" />
              <GraphicalIcon icon="minus-circle" className="--open-icon" />
            </>
          ) : null}
        </div>
      </summary>
      {hints.map((hint, idx) => (
        <div
          className="c-textual-content --small"
          key={idx}
          dangerouslySetInnerHTML={{ __html: hint }}
        ></div>
      ))}
    </details>
  )
}
