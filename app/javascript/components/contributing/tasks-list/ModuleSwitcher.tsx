// i18n-namespace: components/contributing
import React from 'react'
import { TaskModule } from '@/components/types'
import { GraphicalIcon } from '@/components/common'
import { MultipleSelect } from '@/components/common/MultipleSelect'
import { ModuleTag } from './task/ModuleTag'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const ModuleOption = ({
  option: module,
}: {
  option: TaskModule
}): JSX.Element => {
  const { t } = useAppTranslation('components/contributing')

  switch (module) {
    case 'generator':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">
              {t('tasksList.moduleSwitcher.generator')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'concept-exercise':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">
              {t('tasksList.moduleSwitcher.learningExercise')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'practice-exercise':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">
              {t('tasksList.moduleSwitcher.practiceExercise')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'concept':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">{t('tasksList.moduleSwitcher.concept')}</div>
          </div>
        </React.Fragment>
      )
    case 'test-runner':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">
              {t('tasksList.moduleSwitcher.testRunner')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'representer':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">
              {t('tasksList.moduleSwitcher.representer')}
            </div>
          </div>
        </React.Fragment>
      )
    case 'analyzer':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">
              {t('tasksList.moduleSwitcher.analyzer')}
            </div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: action }: { value: TaskModule[] }) => {
  const { t } = useAppTranslation('components/contributing')

  if (action.length > 1) {
    return <>{t('tasksList.moduleSwitcher.multiple')}</> // You can localize this if needed
  }

  switch (action[0]) {
    case 'generator':
      return <>{t('tasksList.moduleSwitcher.generator')}</>
    case 'concept-exercise':
      return <>{t('tasksList.moduleSwitcher.learningExercise')}</>
    case 'practice-exercise':
      return <>{t('tasksList.moduleSwitcher.practiceExercise')}</>
    case 'concept':
      return <>{t('tasksList.moduleSwitcher.concept')}</>
    case 'test-runner':
      return <>{t('tasksList.moduleSwitcher.testRunner')}</>
    case 'representer':
      return <>{t('tasksList.moduleSwitcher.representer')}</>
    case 'analyzer':
      return <>{t('tasksList.moduleSwitcher.analyzer')}</>
    case undefined:
      return <>{t('tasksList.moduleSwitcher.allModules')}</>
  }
}

const ResetComponent = () => {
  const { t } = useAppTranslation('components/contributing')
  return (
    <React.Fragment>
      <GraphicalIcon icon="task-module" className="task-icon" />
      <div className="info">
        <div className="title">{t('tasksList.moduleSwitcher.allModules')}</div>
      </div>
    </React.Fragment>
  )
}

export const ModuleSwitcher = ({
  value,
  setValue,
}: {
  value: TaskModule[]
  setValue: (module: TaskModule[]) => void
}): JSX.Element => {
  return (
    <MultipleSelect<TaskModule>
      options={[
        'generator',
        'concept-exercise',
        'practice-exercise',
        'concept',
        'test-runner',
        'representer',
        'analyzer',
      ]}
      value={value}
      setValue={setValue}
      label="Module"
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={ModuleOption}
      className="module-switcher"
    />
  )
}
