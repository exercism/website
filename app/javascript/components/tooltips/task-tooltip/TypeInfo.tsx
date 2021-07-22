import React from 'react'
import { TypeIcon } from '../../contributing/tasks-list/task/TypeIcon'
import { TaskType } from '../../types'

export const TypeInfo = ({ type }: { type: TaskType }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <TypeIcon type={type} />
      </div>
      <div className="details">
        <TypeDetails type={type} />
      </div>
    </section>
  )
}

const TypeDetails = ({ type }: { type: TaskType }): JSX.Element => {
  return (
    <h3>
      This is a <strong>{type}</strong> type task
    </h3>
  )
}
