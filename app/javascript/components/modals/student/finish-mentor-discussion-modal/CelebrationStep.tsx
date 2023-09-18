import React from 'react'
import { GraphicalIcon } from '../../../common'

type Links = {
  exercise: string
}

/* TODO: (required) Use correct gif */
export const CelebrationStep = ({
  mentorHandle,
  links,
}: {
  mentorHandle: string
  links: Links
}): JSX.Element => {
  return (
    <section className="celebrate-step neon-cat">
      <img
        src="https://media.giphy.com/media/sIIhZliB2McAo/source.gif"
        className="gif"
      />
      <h2>Thank you for leaving a testimonial 💙</h2>
      <p>
        <strong>You&apos;ve helped make {mentorHandle}&apos;s day.</strong>
        Please be sure to share your experience of Exercism with others.
      </p>
      <a href={links.exercise} className="btn-primary btn-l">
        <span>Back to the exercise</span>
        <GraphicalIcon icon="arrow-right" />
      </a>
    </section>
  )
}
