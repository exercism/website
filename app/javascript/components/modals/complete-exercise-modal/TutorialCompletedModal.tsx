import React from 'react'
import { Modal } from '../Modal'
import { GraphicalIcon } from '../../common'
import { ExerciseCompletion } from '../CompleteExerciseModal'

export const TutorialCompletedModal = ({
  open,
  completion,
}: {
  open: boolean
  completion: ExerciseCompletion
}): JSX.Element => {
  return (
    <Modal
      cover={true}
      open={open}
      className="m-completed-tutorial-exercise"
      onClose={() => {}}
    >
      <GraphicalIcon icon="hello-world" category="graphics" />
      <h2>You’ve completed “{completion.exercise.title}”</h2>
      <h3>
        This is just the start of your journey on the {completion.track.title}{' '}
        track 🚀
      </h3>
      <p>
        You’re now ready to get stuck into some{' '}
        <a href={completion.track.links.exercises}>real exercises</a>.
        {completion.track.course ? (
          <>
            <br />
            We’ve also revealed {completion.track.title}’s{' '}
            {completion.track.numConcepts} concepts for you to take a look at.
          </>
        ) : (
          ''
        )}
      </p>
      <div className="info">
        Once you start your next exercise, you’ll have access to the mentoring
        section on your track too.
      </div>
      <div className="btns">
        {completion.track.course ? (
          <a
            href={completion.track.links.concepts}
            className="btn-primary btn-m"
          >
            <span>Show me the Concepts</span>
            <GraphicalIcon icon="arrow-right" />
          </a>
        ) : (
          <a
            href={completion.track.links.exercises}
            className="btn-primary btn-m"
          >
            Show me more exercises
          </a>
        )}
        <a href={completion.exercise.links.self} className="btn">
          Return to “{completion.exercise.title}”
        </a>
      </div>
    </Modal>
  )
}
