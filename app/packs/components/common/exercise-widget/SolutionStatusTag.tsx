import React from 'react'
import { SolutionStatus, Size } from '../../types'

export const SolutionStatusTag = ({
  status,
  size,
}: {
  status: SolutionStatus
  size: Size
}): JSX.Element => {
  const sizeClassName = size ? `--${size}` : ''

  switch (status) {
    case 'published':
      return (
        <div className={`c-exercise-status-tag --published ${sizeClassName}`}>
          Published
        </div>
      )
    case 'completed':
      return (
        <div className={`c-exercise-status-tag --completed ${sizeClassName}`}>
          Completed
        </div>
      )
    case 'started':
    case 'iterated':
      return (
        <div className={`c-exercise-status-tag --in-progress ${sizeClassName}`}>
          In-progress
        </div>
      )
  }
}
