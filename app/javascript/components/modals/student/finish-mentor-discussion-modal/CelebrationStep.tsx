import React, { useEffect } from 'react'
import { GraphicalIcon } from '../../../common'

type Links = {
  exercise: string
}

export const CelebrationStep = ({
  mentorHandle,
  links,
  setContainerModalMaxWidth,
}: {
  mentorHandle: string
  links: Links
  setContainerModalMaxWidth: React.Dispatch<React.SetStateAction<string>>
}): JSX.Element => {
  useEffect(() => {
    setContainerModalMaxWidth('900px')
    return () => setContainerModalMaxWidth('100%')
  }, [setContainerModalMaxWidth])

  return (
    <section className="celebrate-step neon-cat">
      <img src="https://i.gifer.com/17xo.gif" className="gif" height={80} />
      <h2>Thank you for leaving a testimonial 💙</h2>
      <p>
        <strong>You&apos;ve helped make {mentorHandle}&apos;s day.</strong>
        Please share your experience of Exercism with others.
      </p>
      <a href={links.exercise} className="btn-enhanced btn-l --disabled">
        <span>Back to the exercise</span>
        <GraphicalIcon icon="arrow-right" />
      </a>
    </section>
  )
}
