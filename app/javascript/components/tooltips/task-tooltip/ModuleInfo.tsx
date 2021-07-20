import React from 'react'
import { ModuleTag } from '../../contributing/tasks-list/task/ModuleTag'
import { TaskModule } from '../../types'

export const ModuleInfo = ({ module }: { module: TaskModule }): JSX.Element => {
  return (
    <div className="info">
      <ModuleTag module={module} />
      <ModuleDetails module={module} />
    </div>
  )
}

const ModuleDetails = ({ module }: { module: TaskModule }): JSX.Element => {
  switch (module) {
    case 'analyzer':
      return (
        <p>
          This task is about <strong>Analyzers</strong>
        </p>
      )
    case 'concept':
      return (
        <p>
          This task is about <strong>Concepts</strong>
        </p>
      )
    case 'concept-exercise':
      return (
        <p>
          This task is about <strong>Concept Exercises</strong>
        </p>
      )
    case 'generator':
      return (
        <p>
          This task is about <strong>Generators</strong>
        </p>
      )
    case 'practice-exercise':
      return (
        <p>
          This task is about <strong>Practice Exercises</strong>
        </p>
      )
    case 'representer':
      return (
        <p>
          This task is about <strong>Representers</strong>
        </p>
      )
    case 'test-runner':
      return (
        <p>
          This task is about <strong>Test Runners</strong>
        </p>
      )
  }
}
