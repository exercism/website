import React from 'react'
import { Tab } from './Tab'
import { TabIndex } from '../Editor'
import { ExerciseInstructions, ExerciseInstructionsTask } from './types'

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

const InstructionsTask = ({ task }: { task: ExerciseInstructionsTask }) => (
  <details className="c-details">
    <summary className="--summary">{task.title}</summary>
    <div dangerouslySetInnerHTML={{ __html: task.text }} />

    <ul>
      {task.hints.map((hint, idx) => (
        <li key={idx} dangerouslySetInnerHTML={{ __html: hint }}></li>
      ))}
    </ul>
  </details>
)
