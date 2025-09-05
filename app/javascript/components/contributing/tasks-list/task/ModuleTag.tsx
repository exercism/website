// i18n-key-prefix: moduleTag
// i18n-namespace: components/contributing/tasks-list/task
import React from 'react'
import { Icon } from '../../../common'
import { TaskModule } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ModuleTag = ({ module }: { module?: TaskModule }): JSX.Element => {
  const { t } = useAppTranslation()
  switch (module) {
    case 'analyzer':
      return (
        <Icon
          icon="automation"
          alt={t('moduleTag.analyzer')}
          className="module"
        />
      )
    case 'representer':
      return (
        <Icon
          icon="task-module-representer"
          alt={t('moduleTag.representer')}
          className="module"
        />
      )
    case 'concept-exercise':
      return (
        <Icon
          icon="concept-exercise"
          alt={t('moduleTag.learningExercise')}
          className="module"
        />
      )
    case 'practice-exercise':
      return (
        <Icon
          icon="exercises"
          alt={t('moduleTag.practiceExercise')}
          className="module"
        />
      )
    case 'test-runner':
      return (
        <Icon icon="tests" alt={t('moduleTag.testRunner')} className="module" />
      )
    case 'generator':
      return (
        <Icon
          icon="task-module-generator"
          alt={t('moduleTag.trackGenerators')}
          className="module"
        />
      )
    case 'concept':
      return (
        <Icon
          icon="task-module-concept"
          alt={t('moduleTag.trackConcepts')}
          className="module"
        />
      )
    default:
      return <div className="module blank" />
  }
}
