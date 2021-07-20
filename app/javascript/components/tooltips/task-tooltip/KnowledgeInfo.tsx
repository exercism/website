import React from 'react'
import { KnowledgeIcon } from '../../contributing/tasks-list/task/KnowledgeIcon'
import { TaskKnowledge } from '../../types'

export const KnowledgeInfo = ({
  knowledge,
}: {
  knowledge: TaskKnowledge
}): JSX.Element => {
  return (
    <div className="info">
      <KnowledgeIcon knowledge={knowledge} />
      <KnowledgeDetails knowledge={knowledge} />
    </div>
  )
}

const KnowledgeDetails = ({
  knowledge,
}: {
  knowledge: TaskKnowledge
}): JSX.Element => {
  switch (knowledge) {
    case 'none':
      return (
        <p>
          This task requires <strong>No</strong> knowledge
        </p>
      )
    case 'elementary':
      return (
        <p>
          This task requires <strong>Elementary</strong> knowledge
        </p>
      )
    case 'intermediate':
      return (
        <p>
          This task requires <strong>Intermediate</strong> knowledge
        </p>
      )
    case 'advanced':
      return (
        <p>
          This task requires <strong>Advanced</strong> knowledge
        </p>
      )
  }
}
