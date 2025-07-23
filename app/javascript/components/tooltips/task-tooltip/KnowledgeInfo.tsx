import React from 'react'
import { KnowledgeTag } from '../../contributing/tasks-list/task/KnowledgeTag'
import { TaskKnowledge, TaskModule } from '../../types'
import { descriptionForModule } from './Summary'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/tooltips/task-tooltip')
  const desc = descriptionForModule(module)
  switch (knowledge) {
    case 'none':
      return (
        <>
          <h3>{t('knowledgeInfo.noExistingKnowledge')}</h3>
          <p>{t('knowledgeInfo.perfectForFirstContribution')}</p>
        </>
      )
    case 'elementary':
      return (
        <>
          <h3>{t('knowledgeInfo.elementaryKnowledge')}</h3>
          <p>{t('knowledgeInfo.littleBitAboutExercism')}</p>
        </>
      )
    case 'intermediate':
      return (
        <>
          <h3>{t('knowledgeInfo.intermediateKnowledge')}</h3>
          <p>
            {t('knowledgeInfo.keyPrinciplesOfArea', {
              desc: desc ? desc : t('summary.exercism'),
            })}
          </p>
        </>
      )
    case 'advanced':
      return (
        <>
          <h3>{t('knowledgeInfo.advancedKnowledge')}</h3>
          <p>
            {t('knowledgeInfo.solidUnderstandingOfArea', {
              desc: desc ? desc : t('summary.exercism'),
            })}
          </p>
        </>
      )
  }
}
