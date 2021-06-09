import React from 'react'
import { TaskType as TaskTypeProps } from '../../../types'
import { GraphicalIcon } from '../../../common'

export const TaskType = ({ type }: { type?: TaskTypeProps }): JSX.Element => {
  return (
    <div className="type c-tag --small">
      <GraphicalIcon icon={`task-type-${type}`} />
      {type}
    </div>
  )
}
