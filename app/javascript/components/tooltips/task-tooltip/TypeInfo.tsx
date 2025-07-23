import React from 'react'
import { TypeIcon } from '../../contributing/tasks-list/task/TypeIcon'
import { TaskType } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TypeInfo = ({ type }: { type: TaskType }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <TypeIcon type={type} />
      </div>
      <div className="details">
        <TypeDetails type={type} />
      </div>
    </section>
  )
}

const TypeDetails = ({ type }: { type: TaskType }): JSX.Element => {
  const { t } = useAppTranslation('components/tooltips/task-tooltip')

  switch (type) {
    case 'ci':
      return (
        <>
          <h3>{t('typeInfo.continuousIntegration')}</h3>
          <p>{t('typeInfo.githubActions')}</p>
        </>
      )
    case 'coding':
      return (
        <>
          <h3>{t('typeInfo.codingTask')}</h3>
          <p>{t('typeInfo.productionLevelCode')}</p>
        </>
      )
    case 'content':
      return (
        <>
          <h3>{t('typeInfo.studentFacingContent')}</h3>
          <p>{t('typeInfo.writingInMarkdown')}</p>
        </>
      )
    case 'docker':
      return (
        <>
          <h3>{t('typeInfo.writingDockerfiles')}</h3>
          <p>{t('typeInfo.improveDockerfiles')}</p>
        </>
      )
    case 'docs':
      return (
        <>
          <h3>{t('typeInfo.writingDocs')}</h3>
          <p>{t('typeInfo.docsImportant')}</p>
        </>
      )
  }
}
