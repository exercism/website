import React from 'react'
import { TaskAction } from '../../types'
import { MultipleSelect } from '../../common/MultipleSelect'
import { GraphicalIcon } from '../../common'

const ActionOption = ({
  option: action,
}: {
  option: TaskAction
}): JSX.Element => {
  switch (action) {
    case 'create':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-action-create" className="task-icon" />
          <div className="info">
            <div className="title">Create</div>
            <div className="description">Work on something from scratch</div>
          </div>
        </React.Fragment>
      )
    case 'sync':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-action-sync" className="task-icon" />
          <div className="info">
            <div className="title">Sync</div>
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
            <div className="title">Improve</div>
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
            <div className="title">Proofread</div>
            <div className="description">Proofread text</div>
          </div>
        </React.Fragment>
      )
    case 'fix':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-action-fix" className="task-icon" />
          <div className="info">
            <div className="title">Fix</div>
            <div className="description">Fix an issue</div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: action }: { value: TaskAction[] }) => {
  if (action.length > 1) {
    return <>Multiple</>
  }

  switch (action[0]) {
    case 'create':
      return <>Create</>
    case 'sync':
      return <>Sync</>
    case 'improve':
      return <>Improve</>
    case 'proofread':
      return <>Proofread</>
    case 'fix':
      return <>Fix</>
    case undefined:
      return <>All</>
  }
}

const ResetComponent = () => {
  return (
    <React.Fragment>
      <GraphicalIcon icon="task-action" className="task-icon" />
      <div className="info">
        <div className="title">All actions</div>
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
