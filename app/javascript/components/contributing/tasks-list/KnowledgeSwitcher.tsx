import React from 'react'
import { TaskKnowledge } from '../../types'
import { ExercismMultipleSelect } from '../../common/ExercismMultipleSelect'
import { KnowledgeIcon } from './task/KnowledgeIcon'

const KnowledgeOption = ({
  option: knowledge,
}: {
  option: TaskKnowledge
}): JSX.Element => {
  switch (knowledge) {
    case 'none':
      return (
        <React.Fragment>
          <div className="task-icon">
            <KnowledgeIcon knowledge={knowledge} />
          </div>
          <div className="info">
            <div className="title">None</div>
            <div className="description">
              No existing Exercism knowledge required
            </div>
          </div>
        </React.Fragment>
      )
    case 'elementary':
      return (
        <React.Fragment>
          <div className="task-icon">
            <KnowledgeIcon knowledge={knowledge} />
          </div>
          <div className="info">
            <div className="title">Elementary</div>
            <div className="description">
              Little Exercism knowledge required
            </div>
          </div>
        </React.Fragment>
      )
    case 'intermediate':
      return (
        <React.Fragment>
          <div className="task-icon">
            <KnowledgeIcon knowledge={knowledge} />
          </div>
          <div className="info">
            <div className="title">Intermediate</div>
            <div className="description">
              Quite a bit of Exercism knowledge required
            </div>
          </div>
        </React.Fragment>
      )
    case 'advanced':
      return (
        <React.Fragment>
          <div className="task-icon">
            <KnowledgeIcon knowledge={knowledge} />
          </div>
          <div className="info">
            <div className="title">Advanced</div>
            <div className="description">
              Comprehensive Exercism knowledge required
            </div>
          </div>
        </React.Fragment>
      )
  }
}

const SelectedComponent = ({
  value: knowledge,
}: {
  value: TaskKnowledge[]
}) => {
  if (knowledge.length > 1) {
    return <div>Multiple</div>
  }

  switch (knowledge[0]) {
    case 'none':
      return <div>None</div>
    case 'elementary':
      return <div>Elementary</div>
    case 'intermediate':
      return <div>Intermediate</div>
    case 'advanced':
      return <div>Advanced</div>
    case undefined:
      return <div>Any knowledge</div>
  }
}

const ResetComponent = () => {
  return (
    <React.Fragment>
      <div className="info">
        <div className="title">Any knowledge</div>
      </div>
    </React.Fragment>
  )
}

export const KnowledgeSwitcher = ({
  value,
  setValue,
}: {
  value: TaskKnowledge[]
  setValue: (knowledge: TaskKnowledge[]) => void
}): JSX.Element => {
  return (
    <ExercismMultipleSelect<TaskKnowledge>
      options={['none', 'elementary', 'intermediate', 'advanced']}
      value={value}
      setValue={setValue}
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={KnowledgeOption}
      // TODO: Change these class names
      componentClassName="c-track-switcher --small"
      buttonClassName="current-track"
      panelClassName="c-track-switcher-dropdown"
    />
  )
}
