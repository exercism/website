import React from 'react'
import { GraphicalIcon } from '../../../common'

export const ReputationInfo = (): JSX.Element => {
  return (
    <div className="reputation-info">
      <div className="inner">
        <GraphicalIcon icon="reputation" />
        <div className="info">
          <h3>Reputation &amp; testimonials</h3>
          <p>
            You&apos;ll gain <strong>6 reputation</strong> for each successful
            mentoring session. At the end of every discussion, students are
            invited to leave you a testimonial.
          </p>
        </div>
      </div>
    </div>
  )
}
