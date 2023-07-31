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
            This task requires you to <strong>create</strong> something new.
          </h3>
          <p>This means you&apos;ll be building something from scratch.</p>
        </>
      )
    case 'fix':
      return (
        <>
          <h3>
            This task requires you to <strong>fix</strong> something broken.
          </h3>
          <p>
            This means you&apos;ll be taking something that&apos;s currently not
            working and fixing it.
          </p>
        </>
      )
    case 'improve':
      return (
        <>
          <h3>
            This task requires you to <strong>improve</strong> something.
          </h3>
          <p>
            We often merge things at Exercism that take the project forward and
            add follow-up issues to improve things. This is an opportunity to
            add a feature or improvement.
          </p>
        </>
      )
    case 'proofread':
      return (
        <>
          <h3>
            This task requires you to <strong>proofread</strong>.
          </h3>
          <p>
            Help checks our docs and content make sense, are grammatical, and
            are consumable by non-native speakers.
          </p>
        </>
      )
    case 'sync':
      return (
        <>
          <h3>
            This task requires you to <strong>sync</strong> content to the
            latest verisons.
          </h3>
          <p>
            Exercism have a central repository of exercises that are updated by
            a cross-language team. This task involves updating one Track&apos;s
            implementation to the latest version of an Exercise.
          </p>
        </>
      )
  }
}
