import React from 'react'
import { TaskModule } from '../../types'
import { ExercismMultipleSelect } from '../../common/ExercismMultipleSelect'
import { ModuleTag } from './task/ModuleTag'

const ModuleOption = ({
  option: module,
}: {
  option: TaskModule
}): JSX.Element => {
  switch (module) {
    case 'generator':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">Generator</div>
          </div>
        </React.Fragment>
      )
    case 'concept-exercise':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">Concept Exercise</div>
          </div>
        </React.Fragment>
      )
    case 'practice-exercise':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">Practice Exercise</div>
          </div>
        </React.Fragment>
      )
    case 'concept':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">Concept</div>
          </div>
        </React.Fragment>
      )
    case 'test-runner':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">Test Runner</div>
          </div>
        </React.Fragment>
      )
    case 'representer':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">Representer</div>
          </div>
        </React.Fragment>
      )
    case 'analyzer':
      return (
        <React.Fragment>
          <ModuleTag module={module} />
          <div className="info">
            <div className="title">Analyzer</div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({ value: action }: { value: TaskModule[] }) => {
  if (action.length > 1) {
    return <div>Multiple</div>
  }

  switch (action[0]) {
    case 'generator':
      return <div>Generator</div>
    case 'concept-exercise':
      return <div>Concept Exercise</div>
    case 'practice-exercise':
      return <div>Practice Exercise</div>
    case 'concept':
      return <div>Concept</div>
    case 'test-runner':
      return <div>Test Runner</div>
    case 'representer':
      return <div>Representer</div>
    case 'analyzer':
      return <div>Analyzer</div>
    case undefined:
      return <div>All modules</div>
  }
}

const ResetComponent = () => {
  return (
    <React.Fragment>
      <div className="info">
        <div className="title">All modules</div>
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
    <ExercismMultipleSelect<TaskModule>
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
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={ModuleOption}
      // TODO: Change these class names
      componentClassName="c-track-switcher --small"
      buttonClassName="current-track"
      panelClassName="c-track-switcher-dropdown"
    />
  )
}
