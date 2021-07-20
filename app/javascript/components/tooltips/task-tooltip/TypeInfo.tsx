import React from 'react'
import { TypeIcon } from '../../contributing/tasks-list/task/TypeIcon'
import { TaskType } from '../../types'

export const TypeInfo = ({ type }: { type: TaskType }): JSX.Element => {
  return (
    <div className="info">
      <TypeIcon type={type} />
      <TypeDetails type={type} />
    </div>
  )
}

const TypeDetails = ({ type }: { type: TaskType }): JSX.Element => {
  return (
    <p>
      This is a <strong>{type}</strong> type task
    </p>
  )
}
