// i18n-key-prefix: tasksList.actionSwitcher
// i18n-namespace: components/contributing
import React from 'react'
import { TaskAction } from '../../types'
import { MultipleSelect } from '../../common/MultipleSelect'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const ActionOption = ({
  option: action,
}: {
  option: TaskAction
}): JSX.Element => {
  const { t } = useAppTranslation()
  switch (action) {
    case 'create':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-action-create" className="task-icon" />
          <div className="info">
            <div className="title">{t('tasksList.actionSwitcher.create')}</div>
            <div className="description">Work on something from scratch</div>
          </div>
        </React.Fragment>
      )
    case 'sync':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-action-sync" className="task-icon" />
          <div className="info">
            <div className="title">{t('tasksList.actionSwitcher.sync')}</div>
            <div className="description">
              Sync content with its latest version
            </div>
          </div>
        </React.Fragment>
      )
    case 'improve':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-action-improve" className="task-icon" />
          <div className="info">
            <div className="title">{t('tasksList.actionSwitcher.improve')}</div>
            <div className="description">
              Improve existing functionality / content
            </div>
          </div>
        </React.Fragment>
      )
    case 'proofread':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-action-proofread" className="task-icon" />
          <div className="info">
            <div className="title">
              {t('tasksList.actionSwitcher.proofread')}
            </div>
            <div className="description">Proofread text</div>
          </div>
        </React.Fragment>
      )
    case 'fix':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-action-fix" className="task-icon" />
          <div className="info">
            <div className="title">{t('tasksList.actionSwitcher.fix')}</div>
            <div className="description">Fix an issue</div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: action }: { value: TaskAction[] }) => {
  const { t } = useAppTranslation()
  if (action.length > 1) {
    return <>Multiple</>
  }

  switch (action[0]) {
    case 'create':
      return <>{t('tasksList.actionSwitcher.create')}</>
    case 'sync':
      return <>{t('tasksList.actionSwitcher.sync')}</>
    case 'improve':
      return <>{t('tasksList.actionSwitcher.improve')}</>
    case 'proofread':
      return <>{t('tasksList.actionSwitcher.proofread')}</>
    case 'fix':
      return <>{t('tasksList.actionSwitcher.fix')}</>
    case undefined:
      return <>{t('tasksList.actionSwitcher.all')}</>
  }
}

const ResetComponent = () => {
  const { t } = useAppTranslation()
  return (
    <React.Fragment>
      <GraphicalIcon icon="task-action" className="task-icon" />
      <div className="info">
        <div className="title">{t('tasksList.actionSwitcher.all')}</div>
      </div>
    </React.Fragment>
  )
}

export const ActionSwitcher = ({
  value,
  setValue,
}: {
  value: TaskAction[]
  setValue: (action: TaskAction[]) => void
}): JSX.Element => {
  return (
    <MultipleSelect<TaskAction>
      options={['create', 'fix', 'improve', 'proofread', 'sync']}
      value={value}
      setValue={setValue}
      label="Action"
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={ActionOption}
      className="action-switcher"
    />
  )
}
