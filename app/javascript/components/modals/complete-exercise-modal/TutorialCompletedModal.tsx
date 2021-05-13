import React from 'react'
import { Modal } from '../Modal'
import { GraphicalIcon } from '../../common'
import { Track } from '../../types'

export const TutorialCompletedModal = ({
  open,
  track,
}: {
  open: boolean
  track: Track
}): JSX.Element => {
  /* TODO: We need the Track as a variable here to use below. */
  /* Replace "Elixir" and the number of concepts */
  return (
    <Modal
      open={open}
      className="m-completed-tutorial-exercise"
      onClose={() => {}}
    >
      <GraphicalIcon icon="hello-world" category="graphics" />
      <h2>You’ve completed “Hello, World!”</h2>
      <h3>This is just start of your journey on the {track.title} track 🚀</h3>
      <p>
        You’re now ready to get stuck into some{' '}
        <a href={track.links.exercises}>real exercises</a>.
        {track.numConcepts > 0 ? (
          <>
            <br /> We’ve also revealed{' '}
            <a href={track.links.concepts}>
              {track.title}’s {track.numConcepts} concepts
            </a>{' '}
            for you to take a look at.
          </>
        ) : (
          ''
        )}
      </p>
      <div className="info">
        You’ll now have access to the mentoring section on your track too.Go to
        the <a href={track.links.self}>{track.title} track page</a> to check it
        out.
      </div>
      <div className="btns">
        <a href={track.links.exercises} className="btn-primary btn-m">
          Show me more exercises
        </a>
        <button className="btn">Return to “Hello, World!”</button>
      </div>
    </Modal>
  )
}
