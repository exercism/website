import React from 'react'
import { ModuleTag } from '../../contributing/tasks-list/task/ModuleTag'
import { TaskModule } from '../../types'

export const ModuleInfo = ({ module }: { module: TaskModule }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <ModuleTag module={module} />
      </div>
      <div className="details">
        <ModuleDetails module={module} />
      </div>
    </section>
  )
}

const ModuleDetails = ({ module }: { module: TaskModule }): JSX.Element => {
  switch (module) {
    case 'analyzer':
      return (
        <h3>
          This task is about <strong>Analyzers</strong>
        </h3>
      )
    case 'concept':
      return (
        <h3>
          This task is about <strong>Concepts</strong>
        </h3>
      )
    case 'concept-exercise':
      return (
        <h3>
          This task is about <strong>Concept Exercises</strong>
        </h3>
      )
    case 'generator':
      return (
        <h3>
          This task is about <strong>Generators</strong>
        </h3>
      )
    case 'practice-exercise':
      return (
        <h3>
          This task is about <strong>Practice Exercises</strong>
        </h3>
      )
    case 'representer':
      return (
        <h3>
          This task is about <strong>Representers</strong>
        </h3>
      )
    case 'test-runner':
      return (
        <h3>
          This task is about <strong>Test Runners</strong>
        </h3>
      )
  }
}
