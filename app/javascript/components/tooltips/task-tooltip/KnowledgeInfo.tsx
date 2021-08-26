import React from 'react'
import { KnowledgeTag } from '../../contributing/tasks-list/task/KnowledgeTag'
import { TaskKnowledge, TaskModule } from '../../types'
import { descriptionForModule } from './Summary'

export const KnowledgeInfo = ({
  knowledge,
  module,
}: {
  knowledge: TaskKnowledge
  module?: TaskModule
}): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <KnowledgeTag knowledge={knowledge} />
      </div>
      <div className="details">
        <KnowledgeDetails knowledge={knowledge} module={module} />
      </div>
    </section>
  )
}

const KnowledgeDetails = ({
  knowledge,
  module,
}: {
  knowledge: TaskKnowledge
  module?: TaskModule
}): JSX.Element => {
  const desc = descriptionForModule(module)
  switch (knowledge) {
    case 'none':
      return (
        <>
          <h3>
            This task requires <strong>no</strong> existing Exercism knowledge.
          </h3>
          <p>
            This task is perfect for people making their first contribution to
            Exercism. If you&apos;ve been around a while, considering leaving
            this for someone new 🙂
          </p>
        </>
      )
    case 'elementary':
      return (
        <>
          <h3>
            This task requires <strong>elementary</strong> Exercism knowledge.
          </h3>
          <p>
            You&apos;ll need to know a little bit about how Exercism works, but
            you can work it out during this task. Perfect for first-time
            contributors.
          </p>
        </>
      )
    case 'intermediate':
      return (
        <>
          <h3>
            This task requires <strong>intermediate</strong> Exercism knowledge.
          </h3>
          <p>
            You&apos;ll need to know the key principles of{' '}
            {desc ? desc : 'this area'} to work on this task. If you&apos;re not
            familiar, you can learn while doing the task but you might need to
            put in a couple of hours of reading the docs to get up to speed.
          </p>
        </>
      )
    case 'advanced':
      return (
        <>
          <h3>
            This task requires <strong>advanced</strong> Exercism knowledge.
          </h3>
          <p>
            You&apos;ll need to have a solid understanding of
            {desc ? desc : 'this area'} to work on this task. If you don&apos;t,
            you&apos;ll probably need to pair up with someone more experienced
            to work on it.
          </p>
        </>
      )
  }
}
