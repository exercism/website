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
        <>
          <h3>
            For this task, you&apos;ll be working on <strong>Analyzers</strong>
            ..
          </h3>
          <p>
            Analyzers take code and generating automated suggestions for how to
            make code more idiomatic.
          </p>
        </>
      )
    case 'concept':
      return (
        <>
          <h3>
            This task is about <strong>Concepts</strong>.
          </h3>
          <p>
            Concepts are comprised of brief introductions and more complex
            explanations about a programming topic.
          </p>
        </>
      )
    case 'concept-exercise':
      return (
        <>
          <h3>
            This task is about <strong>Learning Exercises</strong>.
          </h3>
          <p>
            Learning Exercises teach one or more Concepts. They are
            signficiantly more complex to make than Practice Exercises.
          </p>
        </>
      )
    case 'generator':
      return (
        <>
          <h3>
            This task is about <strong>Generators</strong>.
          </h3>
          <p>
            Generators are pieces of tooling that Tracks use to keep in sync
            with our central set of exercises.
          </p>
        </>
      )
    case 'practice-exercise':
      return (
        <>
          <h3>
            This task is about <strong>Practice Exercises</strong>.
          </h3>
          <p>
            Most exercises are Practice Exercises - they enable students to
            practice the Concepts they have learnt in Learning Exercises.
          </p>
        </>
      )
    case 'representer':
      return (
        <>
          <h3>
            This task is about <strong>Representers</strong>.
            <p>
              Representers create normalized versions of students&apos;
              submissions, which can have mentoring comments attached to them.
            </p>
          </h3>
        </>
      )
    case 'test-runner':
      return (
        <>
          <h3>
            This task is about <strong>Test Runners</strong>.
          </h3>
          <p>
            Test Runners allow Exercism to run students&apos; code and determine
            whether they pass or fail the tests, and provide useful feedback to
            the student.
          </p>
        </>
      )
  }
}
