import React from 'react'
import { TaskType } from '../../../types'
import { GraphicalIcon } from '../../../common'

export const TypeIcon = ({ type }: { type: TaskType }): JSX.Element => {
  return <GraphicalIcon icon={`task-type-${type}`} />
}
