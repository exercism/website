import React from 'react'
import { SizeTag } from '../../contributing/tasks-list/task/SizeTag'
import { TaskSize } from '../../types'

export const SizeInfo = ({ size }: { size: TaskSize }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <SizeTag size={size} />
      </div>
      <div className="details">
        <SizeDetails size={size} />
      </div>
    </section>
  )
}

const SizeDetails = ({ size }: { size: TaskSize }): JSX.Element => {
  switch (size) {
    case 'tiny':
      return (
        <>
          <h3>
            This is a <strong>tiny task</strong>.
          </h3>
          <p>
            Depending on your experience, you should be able to complete it in a
            few minutes.
          </p>
        </>
      )
    case 'small':
      return (
        <>
          <h3>
            This is a <strong>small task</strong>.
          </h3>
          <p>
            Depending on your experience, you should be able to complete it
            under an hour.
          </p>
        </>
      )
    case 'medium':
      return (
        <>
          <h3>
            This is <strong>medium sized task</strong>.
          </h3>
          <p>
            Depending on your experience, you should be able to complete it in a
            few hours. This is a great task to deepen your knowledge of working
            on Exercism and make a sigificant contribution.
          </p>
        </>
      )
    case 'large':
      return (
        <>
          <h3>
            This is a <strong>large task</strong>.
          </h3>
          <p>
            This will take you many hours to complete. It's a great task to get
            your teeth into and will be a big contribution to Exercism.
          </p>
        </>
      )
    case 'massive':
      return (
        <>
          <h3>
            This task is <strong>a project</strong>.
          </h3>
          <p>
            This will take you days to complete, even if you are experienced
            with contributing to Exercism.
          </p>
        </>
      )
  }
}
