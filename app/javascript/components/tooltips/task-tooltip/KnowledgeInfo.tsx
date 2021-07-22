import React from 'react'
import { KnowledgeTag } from '../../contributing/tasks-list/task/KnowledgeTag'
import { TaskKnowledge } from '../../types'

export const KnowledgeInfo = ({
  knowledge,
}: {
  knowledge: TaskKnowledge
}): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <KnowledgeTag knowledge={knowledge} />
      </div>
      <div className="details">
        <KnowledgeDetails knowledge={knowledge} />
      </div>
    </section>
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
        <h3>
          This task requires <strong>No</strong> knowledge
        </h3>
      )
    case 'elementary':
      return (
        <h3>
          This task requires <strong>Elementary</strong> knowledge
        </h3>
      )
    case 'intermediate':
      return (
        <h3>
          This task requires <strong>Intermediate</strong> knowledge
        </h3>
      )
    case 'advanced':
      return (
        <h3>
          This task requires <strong>Advanced</strong> knowledge
        </h3>
      )
  }
}
