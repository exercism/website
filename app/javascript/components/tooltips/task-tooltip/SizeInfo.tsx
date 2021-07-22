import React from 'react'
import { SizeTag } from '../../contributing/tasks-list/task/SizeTag'
import { TaskSize } from '../../types'

export const SizeInfo = ({ size }: { size: TaskSize }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <SizeTag size={size} />
      </div>
      <div className="details">
        <SizeDetails size={size} />
      </div>
    </section>
  )
}

const SizeDetails = ({ size }: { size: TaskSize }): JSX.Element => {
  switch (size) {
    case 'tiny':
      return (
        <h3>
          This task is <strong>Tiny</strong>
        </h3>
      )
    case 'small':
      return (
        <h3>
          This task is <strong>Small</strong>
        </h3>
      )
    case 'medium':
      return (
        <h3>
          This task is <strong>Medium</strong>
        </h3>
      )
    case 'large':
      return (
        <h3>
          This task is <strong>Large</strong>
        </h3>
      )
    case 'massive':
      return (
        <h3>
          This task is <strong>Massive</strong>
        </h3>
      )
  }
}
