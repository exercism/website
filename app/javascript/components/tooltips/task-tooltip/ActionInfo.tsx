import React from 'react'
import { ActionIcon } from '../../contributing/tasks-list/task/ActionIcon'
import { TaskAction } from '../../types'

export const ActionInfo = ({ action }: { action: TaskAction }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <ActionIcon action={action} />
      </div>
      <div className="details">
        <ActionDetails action={action} />
      </div>
    </section>
  )
}

const ActionDetails = ({ action }: { action: TaskAction }): JSX.Element => {
  switch (action) {
    case 'create':
      return (
        <>
          <h3>
            This task requires you to <strong>Create</strong>
          </h3>
          <p>This means you’ll be bulding something from scratch.</p>
        </>
      )
    case 'fix':
      return (
        <>
          <h3>
            This task requires you to <strong>Fix</strong>
          </h3>
          <p>
            This means you’ll be bulding taking something that's currently not
            working and fixing it.
          </p>
        </>
      )
    case 'improve':
      return (
        <>
          <h3>
            This task requires you to <strong>Improve</strong>
          </h3>
          <p></p>
        </>
      )
    case 'proofread':
      return (
        <>
          <h3>
            This task requires you to <strong>Proofread</strong>
          </h3>
          <p></p>
        </>
      )
    case 'sync':
      return (
        <>
          <h3>
            This task requires you to <strong>Sync</strong>
          </h3>
          <p></p>
        </>
      )
  }
}
