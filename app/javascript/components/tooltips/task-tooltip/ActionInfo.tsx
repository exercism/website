import React from 'react'
import { ActionIcon } from '../../contributing/tasks-list/task/ActionIcon'
import { TaskAction } from '../../types'

export const ActionInfo = ({ action }: { action: TaskAction }): JSX.Element => {
  return (
    <div className="info">
      <ActionIcon action={action} />
      <ActionDetails action={action} />
    </div>
  )
}

const ActionDetails = ({ action }: { action: TaskAction }): JSX.Element => {
  switch (action) {
    case 'create':
      return (
        <p>
          This task requires you to <strong>Create</strong>
        </p>
      )
    case 'fix':
      return (
        <p>
          This task requires you to <strong>Fix</strong>
        </p>
      )
    case 'improve':
      return (
        <p>
          This task requires you to <strong>Improve</strong>
        </p>
      )
    case 'proofread':
      return (
        <p>
          This task requires you to <strong>Proofread</strong>
        </p>
      )
    case 'sync':
      return (
        <p>
          This task requires you to <strong>Sync</strong>
        </p>
      )
  }
}
