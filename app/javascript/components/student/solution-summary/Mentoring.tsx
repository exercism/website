import React from 'react'
import { GraphicalIcon, Icon } from '../../common'

export const Mentoring = ({ link }: { link: string }): JSX.Element => {
  return (
    <div className="mentoring">
      <GraphicalIcon icon="graphic-mentoring-screen" className="header-icon" />
      <h3>Get mentored by a human</h3>
      <p>
        On average, students iterate a further 3.5 times when mentored on a
        solution.
      </p>
      <div className="c-combo-button">
        <button className="--editor-segment">Request Mentoring</button>
        <button className="--dropdown-segment">
          <GraphicalIcon icon="chevron-down" />
        </button>
      </div>
      <a href={link} className="learn-more">
        Learn more
        <Icon icon="external-link" alt="Opens in new tab" />
      </a>
    </div>
  )
}
