// i18n-key-prefix: knowledgeTag
// i18n-namespace: components/contributing/tasks-list/task
import React from 'react'
import { TaskKnowledge } from '../../../types'
import { GraphicalIcon } from '../../../common'
import { KnowledgeIcon } from './KnowledgeIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const KnowledgeTag = ({
  knowledge,
}: {
  knowledge?: TaskKnowledge
}): JSX.Element => {
  const { t } = useAppTranslation('components/contributing/tasks-list/task')

  switch (knowledge) {
    case 'none':
      return (
        <div className="knowledge-tag">
          <GraphicalIcon icon="task-knowledge" />
          <KnowledgeIcon knowledge={knowledge} />
          <div className="sr-only">{t('knowledgeTag.none')}</div>
        </div>
      )
    case 'elementary':
      return (
        <div className="knowledge-tag">
          <GraphicalIcon icon="task-knowledge" />
          <KnowledgeIcon knowledge={knowledge} />
          <div className="sr-only">{t('knowledgeTag.elementary')}</div>
        </div>
      )
    case 'intermediate':
      return (
        <div className="knowledge-tag">
          <GraphicalIcon icon="task-knowledge" />
          <KnowledgeIcon knowledge={knowledge} />
          <div className="sr-only">{t('knowledgeTag.intermediate')}</div>
        </div>
      )
    case 'advanced':
      return (
        <div className="knowledge-tag">
          <GraphicalIcon icon="task-knowledge" />
          <KnowledgeIcon knowledge={knowledge} />
          <div className="sr-only">{t('knowledgeTag.advanced')}</div>
        </div>
      )
    default:
      return <div className="knowledge-tag blank" />
  }
}
