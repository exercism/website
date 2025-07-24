import React from 'react'
import { ModuleTag } from '../../contributing/tasks-list/task/ModuleTag'
import { TaskModule } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const ModuleInfo = ({ module }: { module: TaskModule }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <ModuleTag module={module} />
      </div>
      <div className="details">
        <ModuleDetails module={module} />
      </div>
    </section>
  )
}

const ModuleDetails = ({ module }: { module: TaskModule }): JSX.Element => {
  const { t } = useAppTranslation('components/tooltips/task-tooltip')

  const transComponents = { strong: <strong /> }
  const transNs = 'components/tooltips/task-tooltip'

  switch (module) {
    case 'analyzer':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="moduleInfo.analyzers"
              components={transComponents}
            />
          </h3>
          <p>{t('moduleInfo.analyzersDescription')}</p>
        </>
      )
    case 'concept':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="moduleInfo.concepts"
              components={transComponents}
            />
          </h3>
          <p>{t('moduleInfo.conceptsDescription')}</p>
        </>
      )
    case 'concept-exercise':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="moduleInfo.learningExercises"
              components={transComponents}
            />
          </h3>
          <p>{t('moduleInfo.learningExercisesDescription')}</p>
        </>
      )
    case 'generator':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="moduleInfo.generators"
              components={transComponents}
            />
          </h3>
          <p>{t('moduleInfo.generatorsDescription')}</p>
        </>
      )
    case 'practice-exercise':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="moduleInfo.practiceExercises"
              components={transComponents}
            />
          </h3>
          <p>{t('moduleInfo.practiceExercisesDescription')}</p>
        </>
      )
    case 'representer':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="moduleInfo.representers"
              components={transComponents}
            />
          </h3>
          <p>{t('moduleInfo.representersDescription')}</p>
        </>
      )
    case 'test-runner':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="moduleInfo.testRunners"
              components={transComponents}
            />
          </h3>
          <p>{t('moduleInfo.testRunnersDescription')}</p>
        </>
      )
  }
}
