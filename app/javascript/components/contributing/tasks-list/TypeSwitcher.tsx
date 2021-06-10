import React from 'react'
import { TaskType } from '../../types'
import { ExercismMultipleSelect } from '../../common/ExercismMultipleSelect'
import { GraphicalIcon } from '../../common'

const TypeOption = ({ option: type }: { option: TaskType }): JSX.Element => {
  switch (type) {
    case 'docs':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-docs" className="task-icon" />
          <div className="info">
            <div className="title">Docs</div>
          </div>
        </React.Fragment>
      )
    case 'ci':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-ci" className="task-icon" />
          <div className="info">
            <div className="title">CI</div>
          </div>
        </React.Fragment>
      )
    case 'docker':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-docker" className="task-icon" />
          <div className="info">
            <div className="title">Docker</div>
          </div>
        </React.Fragment>
      )
    case 'coding':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-coding" className="task-icon" />
          <div className="info">
            <div className="title">Coding</div>
          </div>
        </React.Fragment>
      )
    case 'content':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-content" className="task-icon" />
          <div className="info">
            <div className="title">Content</div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: action }: { value: TaskType[] }) => {
  if (action.length > 1) {
    return <div>Multiple</div>
  }

  switch (action[0]) {
    case 'docs':
      return <div>Docs</div>
    case 'ci':
      return <div>CI</div>
    case 'coding':
      return <div>Coding</div>
    case 'docker':
      return <div>Docker</div>
    case 'content':
      return <div>Content</div>
    case undefined:
      return <div>All types</div>
  }
}

const ResetComponent = () => {
  return (
    <React.Fragment>
      <div className="info">
        <div className="title">All types</div>
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
  return (
    <ExercismMultipleSelect<TaskType>
      options={['docs', 'ci', 'coding', 'docker', 'content']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={TypeOption}
      // TODO: Change these class names
      componentClassName="c-track-switcher --small"
      buttonClassName="current-track"
      panelClassName="c-track-switcher-dropdown"
    />
  )
}
