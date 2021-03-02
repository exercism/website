import React from 'react'
import { GraphicalIcon } from '../../common'

export const CommunitySolutions = ({ link }: { link: string }): JSX.Element => {
  return (
    <div className="community-solutions">
      <GraphicalIcon
        icon="graphic-community-solutions"
        className="header-icon"
      />
      <h3>Learn from others&apos; solutions</h3>
      <p>
        Explore their approaches to learn new tips and tricks. Discover popular
        solutions to this exercise.
      </p>
      <a href={link} className="btn-small-discourage">
        View community solutions
      </a>
    </div>
  )
}
