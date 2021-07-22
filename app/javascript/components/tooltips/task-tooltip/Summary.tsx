import React from 'react'
import { Task, TaskAction, TaskModule } from '../../types'

export const Summary = ({ task }: { task: Task }): JSX.Element => {
  return (
    <section className="summary">
      <div className="icon">
        <SummaryTag />
      </div>
      <div className="details">
        <SummaryDetails task={task} />
      </div>
    </section>
  )
}

const SummaryTag = () => {
  return <div className="task-icon">Task</div>
}

export function verbForAction(action?: TaskAction) {
  switch (action) {
    case 'create':
      return <>creating</>
    case 'fix':
      return <>fixing</>
    case 'improve':
      return <>improving</>
    case 'proofread':
      return <>proofreading</>
    case 'sync':
      return <>syncing</>
    default:
      return null
  }
}

export function descriptionForModule(module?: TaskModule) {
  switch (module) {
    case 'analyzer':
      return <>Analyzers</>
    case 'concept':
      return <>Concepts</>
    case 'concept-exercise':
      return <>Learning Exercises</>
    case 'generator':
      return <>Generators</>
    case 'practice-exercise':
      return <>Practice Exercises</>
    case 'representer':
      return <>Representers</>
    case 'test-runner':
      return <>Test Runners</>
    default:
      return null
  }
}

const SummaryDetails = ({ task }: { task: Task }) => {
  const desc = descriptionForModule(task.tags.module)
  const verb = verbForAction(task.tags.action)

  console.log(verb)
  return (
    <h3>
      For this task you will be {verb ? verb : 'working on'}{' '}
      {desc ? desc : 'Exercism'}
      {task.track ? `for the {task.track.title} ` : null}.
    </h3>
  )
}
