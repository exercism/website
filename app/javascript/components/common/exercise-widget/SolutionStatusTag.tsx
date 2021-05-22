import React from 'react'
import { SolutionStatus, Size } from '../../types'

export const SolutionStatusTag = ({
  status,
  size,
}: {
  status: SolutionStatus
  size: Size
}): JSX.Element => {
  switch (status) {
    case 'published':
      return (
        <div className={`c-exercise-status-tag --published --${size}`}>
          Published
        </div>
      )
    case 'completed':
      return (
        <div className={`c-exercise-status-tag --completed --${size}`}>
          Completed
        </div>
      )
    case 'started':
    case 'iterated':
      return (
        <div className={`c-exercise-status-tag --in-progress --${size}`}>
          In-progress
        </div>
      )
  }
}
