import { GraphicalIcon } from '@/components/common'
import React from 'react'
export const Hints = ({
  heading,
  hints,
  expanded,
  collapsable,
}: {
  heading: string
  hints: string[] | undefined
  expanded: boolean
  collapsable: boolean
}): JSX.Element | null => {
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
