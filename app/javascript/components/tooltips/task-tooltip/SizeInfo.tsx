import React from 'react'
import { SizeTag } from '../../contributing/tasks-list/task/SizeTag'
import { TaskSize } from '../../types'

export const SizeInfo = ({ size }: { size: TaskSize }): JSX.Element => {
  return (
    <div className="info">
      <SizeTag size={size} />
      <SizeDetails size={size} />
    </div>
  )
}

const SizeDetails = ({ size }: { size: TaskSize }): JSX.Element => {
  switch (size) {
    case 'tiny':
      return (
        <p>
          This task is <strong>Tiny</strong>
        </p>
      )
    case 'small':
      return (
        <p>
          This task is <strong>Small</strong>
        </p>
      )
    case 'medium':
      return (
        <p>
          This task is <strong>Medium</strong>
        </p>
      )
    case 'large':
      return (
        <p>
          This task is <strong>Large</strong>
        </p>
      )
    case 'massive':
      return (
        <p>
          This task is <strong>Massive</strong>
        </p>
      )
  }
}
