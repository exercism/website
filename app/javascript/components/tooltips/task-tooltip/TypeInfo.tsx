import React from 'react'
import { TypeIcon } from '../../contributing/tasks-list/task/TypeIcon'
import { TaskType } from '../../types'

export const TypeInfo = ({ type }: { type: TaskType }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <TypeIcon type={type} />
      </div>
      <div className="details">
        <TypeDetails type={type} />
      </div>
    </section>
  )
}

const TypeDetails = ({ type }: { type: TaskType }): JSX.Element => {
  switch (type) {
    case 'ci':
      return (
        <>
          <h3>
            In this task you&apos;ll be working on Exercism&apos;s{' '}
            <strong>Continous Integration</strong>.
          </h3>
          <p>You&apos;ll likely be working with GitHub Actions, or similar.</p>
        </>
      )
    case 'coding':
      return (
        <>
          <h3>
            This is a <strong>coding</strong> task.
          </h3>
          <p>
            You&apos;ll be writing production-level code that&apos;s run by
            Exercism, or by our maintainer team to help automate jobs.
          </p>
        </>
      )
    case 'content':
      return (
        <>
          <h3>
            This task involves writing <strong>student-facing content</strong>.
          </h3>
          <p>
            You&apos;ll be primarily writing content in Markdown, along with
            some examples of code, and possible test files, in the relevant
            language.
          </p>
        </>
      )
    case 'docker':
      return (
        <>
          <h3>
            This task involves <strong>writing Dockerfiles</strong>.
          </h3>
          <p>
            Use your Docker expertise to help improve, optimize and shrink our
            Dockerfiles.
          </p>
        </>
      )
    case 'docs':
      return (
        <>
          <h3>
            This task involves <strong>writing docs</strong>.
          </h3>
          <p>
            Docs are one of the most important parts of Exercism - helping both
            contributors and students. Our docs are written in Markdown.
          </p>
        </>
      )
  }
}
