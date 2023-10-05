import React from 'react'
import { TaskType } from '../../types'
import { MultipleSelect } from '../../common/MultipleSelect'
import { GraphicalIcon } from '../../common'

const TypeOption = ({ option: type }: { option: TaskType }): JSX.Element => {
  switch (type) {
    case 'docs':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-docs" className="task-icon" />
          <div className="info">
            <div className="title">Docs</div>
            <div className="description">Help build Exercism's docs</div>
          </div>
        </React.Fragment>
      )
    case 'ci':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-ci" className="task-icon" />
          <div className="info">
            <div className="title">CI</div>
            <div className="description">
              Automation and continuous integration
            </div>
          </div>
        </React.Fragment>
      )
    case 'docker':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-docker" className="task-icon" />
          <div className="info">
            <div className="title">Docker</div>
            <div className="description">Help improve our Dockerfiles</div>
          </div>
        </React.Fragment>
      )
    case 'coding':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-coding" className="task-icon" />
          <div className="info">
            <div className="title">Coding</div>
            <div className="description">Write production code</div>
          </div>
        </React.Fragment>
      )
    case 'content':
      return (
        <React.Fragment>
          <GraphicalIcon icon="task-type-content" className="task-icon" />
          <div className="info">
            <div className="title">Content</div>
            <div className="description">Develop exercises and concepts</div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: action }: { value: TaskType[] }) => {
  if (action.length > 1) {
    return <>Multiple</>
  }

  switch (action[0]) {
    case 'docs':
      return <>Docs</>
    case 'ci':
      return <>CI</>
    case 'coding':
      return <>Coding</>
    case 'docker':
      return <>Docker</>
    case 'content':
      return <>Content</>
    case undefined:
      return <>All</>
  }
}

const ResetComponent = () => {
  return (
    <React.Fragment>
      <GraphicalIcon icon="task-type" className="task-icon" />
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
    <MultipleSelect<TaskType>
      options={['docs', 'ci', 'coding', 'docker', 'content']}
      value={value}
      setValue={setValue}
      label="Type"
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={TypeOption}
      className="type-switcher"
    />
  )
}
