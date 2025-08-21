import React from 'react'
import { KnowledgeTag } from '../../contributing/tasks-list/task/KnowledgeTag'
import { TaskKnowledge, TaskModule } from '../../types'
import { descriptionForModule } from './Summary'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

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

  const transComponents = { strong: <strong /> }
  const transNs = 'components/tooltips/task-tooltip'

  switch (knowledge) {
    case 'none':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="knowledgeInfo.noExistingKnowledge"
              components={transComponents}
            />
          </h3>
          <p>{t('knowledgeInfo.perfectForFirstContribution')}</p>
        </>
      )
    case 'elementary':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="knowledgeInfo.elementaryKnowledge"
              components={transComponents}
            />
          </h3>
          <p>{t('knowledgeInfo.littleBitAboutExercism')}</p>
        </>
      )
    case 'intermediate':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="knowledgeInfo.intermediateKnowledge"
              components={transComponents}
            />
          </h3>
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
          <h3>
            <Trans
              ns={transNs}
              i18nKey="knowledgeInfo.advancedKnowledge"
              components={transComponents}
            />
          </h3>
          <p>
            {t('knowledgeInfo.solidUnderstandingOfArea', {
              desc: desc ? desc : t('summary.exercism'),
            })}
          </p>
        </>
      )
  }
}
