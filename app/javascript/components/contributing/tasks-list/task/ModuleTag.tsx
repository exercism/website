import React from 'react'
import { Icon } from '../../../common'
import { TaskModule } from '../../../types'

export const ModuleTag = ({ module }: { module?: TaskModule }): JSX.Element => {
  switch (module) {
    case 'analyzer':
      return <Icon icon="automation" alt="Analyzer" className="module" />
    case 'representer':
      return (
        <Icon
          icon="task-module-representer"
          alt="Representer"
          className="module"
        />
      )
    case 'concept-exercise':
      return (
        <Icon
          icon="concept-exercise"
          alt="Learning Exercise"
          className="module"
        />
      )
    case 'practice-exercise':
      return (
        <Icon icon="exercises" alt="Practice Exercise" className="module" />
      )
    case 'test-runner':
      return <Icon icon="tests" alt="Test Runner" className="module" />
    case 'generator':
      return (
        <Icon
          icon="task-module-generator"
          alt="Track Generators"
          className="module"
        />
      )
    case 'concept':
      return (
        <Icon
          icon="task-module-concept"
          alt="Track Concepts"
          className="module"
        />
      )
    default:
      return <div className="module blank" />
  }
}
