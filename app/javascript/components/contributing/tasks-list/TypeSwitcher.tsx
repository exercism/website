// i18n-key-prefix: tasksList.typeSwitcher
// i18n-namespace: components/contributing
import React from 'react'
import { TaskType } from '../../types'
import { MultipleSelect } from '../../common/MultipleSelect'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const TypeOption = ({ option: type }: { option: TaskType }): JSX.Element => {
  const { t } = useAppTranslation('components/contributing')
  switch (type) {
    case 'docs':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-docs" className="task-icon" />
          <div className="info">
            <div className="title">{t('tasksList.typeSwitcher.docs')}</div>
            <div className="description">
              {t('tasksList.typeSwitcher.docsDescription')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'ci':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-ci" className="task-icon" />
          <div className="info">
            <div className="title">{t('tasksList.typeSwitcher.ci')}</div>
            <div className="description">
              {t('tasksList.typeSwitcher.ciDescription')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'docker':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-docker" className="task-icon" />
          <div className="info">
            <div className="title">{t('tasksList.typeSwitcher.docker')}</div>
            <div className="description">
              {t('tasksList.typeSwitcher.dockerDescription')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'coding':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-coding" className="task-icon" />
          <div className="info">
            <div className="title">{t('tasksList.typeSwitcher.coding')}</div>
            <div className="description">
              {t('tasksList.typeSwitcher.codingDescription')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'content':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-content" className="task-icon" />
          <div className="info">
            <div className="title">{t('tasksList.typeSwitcher.content')}</div>
            <div className="description">
              {t('tasksList.typeSwitcher.contentDescription')}
            </div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: action }: { value: TaskType[] }) => {
  const { t } = useAppTranslation('components/contributing')
  if (action.length > 1) {
    return <>{t('tasksList.typeSwitcher.multiple')}</>
  }

  switch (action[0]) {
    case 'docs':
      return <>{t('tasksList.typeSwitcher.docs')}</>
    case 'ci':
      return <>{t('tasksList.typeSwitcher.ci')}</>
    case 'coding':
      return <>{t('tasksList.typeSwitcher.coding')}</>
    case 'docker':
      return <>{t('tasksList.typeSwitcher.docker')}</>
    case 'content':
      return <>{t('tasksList.typeSwitcher.content')}</>
    case undefined:
      return <>{t('tasksList.typeSwitcher.allTypes')}</>
  }
}

const ResetComponent = () => {
  const { t } = useAppTranslation('components/contributing')
  return (
    <React.Fragment>
      <GraphicalIcon icon="task-type" className="task-icon" />
      <div className="info">
        <div className="title">{t('tasksList.typeSwitcher.allTypes')}</div>
      </div>
    </React.Fragment>
  )
}

export const TypeSwitcher = ({
  value,
  setValue,
}: {
  value: TaskType[]
  setValue: (types: TaskType[]) => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/contributing')

  return (
    <MultipleSelect<TaskType>
      options={['docs', 'ci', 'coding', 'docker', 'content']}
      value={value}
      setValue={setValue}
      label={t('tasksList.typeSwitcher.label')}
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={TypeOption}
      className="type-switcher"
    />
  )
}
