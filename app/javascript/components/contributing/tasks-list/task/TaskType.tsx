import React from 'react'
import { TaskType as TaskTypeProps } from '../../../types'
import { TypeIcon } from './TypeIcon'

export const TaskType = ({ type }: { type: TaskTypeProps }): JSX.Element => {
  return (
    <div className="type c-tag --small">
      <TypeIcon type={type} />
      {type}
    </div>
  )
}
