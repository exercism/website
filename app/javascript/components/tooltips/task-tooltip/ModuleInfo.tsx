import React from 'react'
import { ModuleTag } from '../../contributing/tasks-list/task/ModuleTag'
import { TaskModule } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  switch (module) {
    case 'analyzer':
      return (
        <>
          <h3>{t('moduleInfo.analyzers')}</h3>
          <p>{t('moduleInfo.analyzersDescription')}</p>
        </>
      )
    case 'concept':
      return (
        <>
          <h3>{t('moduleInfo.concepts')}</h3>
          <p>{t('moduleInfo.conceptsDescription')}</p>
        </>
      )
    case 'concept-exercise':
      return (
        <>
          <h3>{t('moduleInfo.learningExercises')}</h3>
          <p>{t('moduleInfo.learningExercisesDescription')}</p>
        </>
      )
    case 'generator':
      return (
        <>
          <h3>{t('moduleInfo.generators')}</h3>
          <p>{t('moduleInfo.generatorsDescription')}</p>
        </>
      )
    case 'practice-exercise':
      return (
        <>
          <h3>{t('moduleInfo.practiceExercises')}</h3>
          <p>{t('moduleInfo.practiceExercisesDescription')}</p>
        </>
      )
    case 'representer':
      return (
        <>
          <h3>
            {t('moduleInfo.representers')}
            <p>{t('moduleInfo.representersDescription')}</p>
          </h3>
        </>
      )
    case 'test-runner':
      return (
        <>
          <h3>{t('moduleInfo.testRunners')}</h3>
          <p>{t('moduleInfo.testRunnersDescription')}</p>
        </>
      )
  }
}
