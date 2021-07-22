import React from 'react'
import { Task, TaskAction, TaskModule } from '../../types'

export const Summary = ({ task }: { task: Task }): JSX.Element => {
  return (
    <section>
      <SummaryTag />
      <SummaryDetails task={task} />
    </section>
  )
}

const SummaryTag = () => {
  return <div>Task</div>
}

const SummaryVerb = ({ action }: { action?: TaskAction }) => {
  switch (action) {
    case 'create':
      return <span>creating</span>
    case 'fix':
      return <span>fixing</span>
    case 'improve':
      return <span>improving</span>
    case 'proofread':
      return <span>proofreading</span>
    case 'sync':
      return <span>syncing</span>
    default:
      return null
  }
}

const ModuleDescription = ({ module }: { module?: TaskModule }) => {
  switch (module) {
    case 'analyzer':
      return <span>Analyzer</span>
    case 'concept':
      return <span>Concept</span>
    case 'concept-exercise':
      return <span>Concept Exercise</span>
    case 'generator':
      return <span>Generator</span>
    case 'practice-exercise':
      return <span>Practice Exercise</span>
    case 'representer':
      return <span>Representer</span>
    case 'test-runner':
      return <span>Test Runner</span>
    default:
      return null
  }
}

const SummaryDetails = ({ task }: { task: Task }) => {
  return (
    <p>
      For this task you will be <SummaryVerb action={task.tags.action} />{' '}
      {task.tags.type}
      {task.track ? `for the {task.track.title} ` : null}
      <ModuleDescription module={task.tags.module} />
    </p>
  )
}
