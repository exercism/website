import React from 'react'
import { GraphicalIcon } from '@/components/common'

export function FeedbackDetail({
  summary,
  children,
  open,
}: {
  summary: string
  children: React.ReactNode
  open?: boolean
}): JSX.Element {
  return (
    <details open={open} className="c-details feedback">
      <summary className="--summary select-none text-textColor1">
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
