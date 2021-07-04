import React from 'react'
import { GraphicalIcon } from '../../common'

export const CommunitySolutions = ({
  link,
  isTutorial,
}: {
  link: string
  isTutorial: boolean
}): JSX.Element => {
  return (
    <div className="community-solutions">
      <GraphicalIcon
        icon="community-solutions"
        category="graphics"
        className="header-icon"
      />
      <h3>Learn from others&apos; solutions</h3>
      {isTutorial ? (
        <p>
          This is where we’d usually link you to other peoples’ solutions to the
          same exercise.
        </p>
      ) : (
        <>
          <p>
            Explore their approaches to learn new tips and tricks. Discover
            popular solutions to this exercise.
          </p>
          <a href={link} className="btn-small-discourage">
            View community solutions
          </a>
        </>
      )}
    </div>
  )
}
