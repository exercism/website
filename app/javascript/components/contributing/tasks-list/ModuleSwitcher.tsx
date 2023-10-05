import React from 'react'
import { TaskModule } from '@/components/types'
import { GraphicalIcon } from '@/components/common'
import { MultipleSelect } from '@/components/common/MultipleSelect'
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
            <div className="title">Learning Exercise</div>
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
    return <>Multiple</>
  }

  switch (action[0]) {
    case 'generator':
      return <>Generator</>
    case 'concept-exercise':
      return <>Learning Exercise</>
    case 'practice-exercise':
      return <>Practice Exercise</>
    case 'concept':
      return <>Concept</>
    case 'test-runner':
      return <>Test Runner</>
    case 'representer':
      return <>Representer</>
    case 'analyzer':
      return <>Analyzer</>
    case undefined:
      return <>All</>
  }
}

const ResetComponent = () => {
  return (
    <React.Fragment>
      <GraphicalIcon icon="task-module" className="task-icon" />
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
