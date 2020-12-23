import React, { useRef, useState } from 'react'
import { Tab } from './Tab'
import { TabIndex } from '../Editor'
import { ExerciseInstructions, ExerciseInstructionsTask } from './types'
import { TaskHintsModal } from '../modals/TaskHintsModal'
import { GraphicalIcon } from '../common/GraphicalIcon'

export const InstructionsPanel = ({
  introduction,
  instructions,
  exampleSolution,
}: {
  introduction: string
  instructions: ExerciseInstructions
  exampleSolution: string
}) => (
  <Tab.Panel index={TabIndex.INSTRUCTIONS}>
    <section className="instructions">
      <div className="c-textual-content">
        <h2>Introduction</h2>
        <div dangerouslySetInnerHTML={{ __html: introduction }} />

        <Instructions instructions={instructions} />

        <h3 className="text-h3 tw-mt-20">Example solution</h3>
        <pre dangerouslySetInnerHTML={{ __html: exampleSolution }} />
      </div>
    </section>
  </Tab.Panel>
)

const Instructions = ({
  instructions,
}: {
  instructions: ExerciseInstructions
}) => (
  <>
    <h2>Instructions</h2>
    <div dangerouslySetInnerHTML={{ __html: instructions.overview }} />

    {instructions.tasks.map((task, idx) => (
      <InstructionsTask key={idx} task={task} />
    ))}
  </>
)

const InstructionsTask = ({ task }: { task: ExerciseInstructionsTask }) => {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)
  const componentRef = useRef<HTMLDivElement>(null)

  return (
    <details className="c-details">
      <summary className="--summary">
        <span className="--summary-title">{task.title}</span>
        <span className="--closed-icon">
          <GraphicalIcon icon="chevron-right" />
        </span>
        <span className="--open-icon">
          <GraphicalIcon icon="chevron-down" />
        </span>
      </summary>
      <div dangerouslySetInnerHTML={{ __html: task.text }} />

      <div ref={componentRef}>
        <TaskHintsModal
          task={task}
          open={isModalOpen}
          onClose={() => setIsModalOpen(false)}
        />
        <button
          ref={buttonRef}
          className="btn-small-secondary hints-btn"
          onClick={() => {
            setIsModalOpen(true)
          }}
        >
          <GraphicalIcon icon="plus-square" />
          Show Hints
        </button>
      </div>
    </details>
  )
}
