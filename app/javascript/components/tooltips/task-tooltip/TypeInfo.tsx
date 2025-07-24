import React from 'react'
import { TypeIcon } from '../../contributing/tasks-list/task/TypeIcon'
import { TaskType } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

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
          <h3>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.continuousIntegration"
              components={{ storng: <strong /> }}
            />
          </h3>
          <p>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.githubActions"
            />
          </p>
        </>
      )
    case 'coding':
      return (
        <>
          <h3>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.codingTask"
              components={{ storng: <strong /> }}
            />
          </h3>
          <p>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.productionLevelCode"
            />
          </p>
        </>
      )
    case 'content':
      return (
        <>
          <h3>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.studentFacingContent"
              components={{ strong: <strong /> }}
            />
          </h3>
          <p>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.writingInMarkdown"
            />
          </p>
        </>
      )
    case 'docker':
      return (
        <>
          <h3>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.writingDockerfiles"
              components={{ storng: <strong /> }}
            />
          </h3>
          <p>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.improveDockerfiles"
            />
          </p>
        </>
      )
    case 'docs':
      return (
        <>
          <h3>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.writingDocs"
              components={{ storng: <strong /> }}
            />
          </h3>
          <p>
            <Trans
              ns="components/tooltips/task-tooltip"
              i18nKey="typeInfo.docsImportant"
            />
          </p>
        </>
      )
  }
}
