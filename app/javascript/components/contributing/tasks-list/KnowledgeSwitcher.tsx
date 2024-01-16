import React from 'react'
import { TaskKnowledge } from '@/components/types'
import { GraphicalIcon } from '@/components/common'
import { MultipleSelect } from '@/components/common/MultipleSelect'
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
          <div className="knowledge-tag">
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
          <div className="knowledge-tag">
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
          <div className="knowledge-tag">
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
          <div className="knowledge-tag">
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
    return <>Multiple</>
  }

  switch (knowledge[0]) {
    case 'none':
      return <>None</>
    case 'elementary':
      return <>Elementary</>
    case 'intermediate':
      return <>Intermediate</>
    case 'advanced':
      return <>Advanced</>
    case undefined:
      return <>Any</>
  }
}

const ResetComponent = () => {
  return (
    <React.Fragment>
      <GraphicalIcon
        icon="task-knowledge"
        className="task-icon knowledge-reset"
      />
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
    <MultipleSelect<TaskKnowledge>
      options={['none', 'elementary', 'intermediate', 'advanced']}
      value={value}
      setValue={setValue}
      label="Knowledge"
      SelectedComponent={SelectedComponent}
      ResetComponent={ResetComponent}
      OptionComponent={KnowledgeOption}
      className="knowledge-switcher"
    />
  )
}
