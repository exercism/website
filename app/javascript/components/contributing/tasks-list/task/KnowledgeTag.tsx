import React from 'react'
import { TaskKnowledge } from '../../../types'
import { GraphicalIcon } from '../../../common'
import { KnowledgeIcon } from './KnowledgeIcon'

export const KnowledgeTag = ({
  knowledge,
}: {
  knowledge?: TaskKnowledge
}): JSX.Element => {
  switch (knowledge) {
    case 'none':
      return (
        <div className="knowledge">
          <GraphicalIcon icon="task-knowledge" />
          <KnowledgeIcon knowledge={knowledge} />
          <div className="tw-sr-only">Knowledge: none</div>
        </div>
      )
    case 'elementary':
      return (
        <div className="knowledge">
          <GraphicalIcon icon="task-knowledge" />
          <KnowledgeIcon knowledge={knowledge} />
          <div className="tw-sr-only">Knowledge: elementary</div>
        </div>
      )
    case 'intermediate':
      return (
        <div className="knowledge">
          <GraphicalIcon icon="task-knowledge" />
          <KnowledgeIcon knowledge={knowledge} />
          <div className="tw-sr-only">Knowledge: intermediate</div>
        </div>
      )
    case 'advanced':
      return (
        <div className="knowledge">
          <GraphicalIcon icon="task-knowledge" />
          <KnowledgeIcon knowledge={knowledge} />
          <div className="tw-sr-only">Knowledge: advanced</div>
        </div>
      )
    default:
      return <div className="knowledge blank" />
  }
}
