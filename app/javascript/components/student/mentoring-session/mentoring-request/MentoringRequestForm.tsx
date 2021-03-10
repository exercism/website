import React from 'react'
import { CopyToClipboardButton, GraphicalIcon } from '../../../common'
import { Track, Exercise } from '../../MentoringSession'

type Links = {
  learnMoreAboutPrivateMentoring: string
  privateMentoring: string
  mentoringGuide: string
}

export const MentoringRequestForm = ({
  isFirstTimeOnTrack,
  track,
  exercise,
  links,
}: {
  isFirstTimeOnTrack: boolean
  track: Track
  exercise: Exercise
  links: Links
}): JSX.Element => {
  return (
    <div className="mentoring-request-section">
      <div className="direct">
        <h3>
          Send this link to a friend for private mentoring.{' '}
          <a href={links.learnMoreAboutPrivateMentoring}>Learn more</a>.
        </h3>
        <CopyToClipboardButton textToCopy={links.privateMentoring} />
      </div>
      <div className="community">
        <div className="heading">
          <div className="info">
            <h2>It’s time to deepen your knowledge.</h2>
            <p>
              Start a mentoring discussion on <strong>{exercise.title}</strong>{' '}
              to discover new and exciting ways to approach it. Expand and
              deepen your knowledge.
            </p>
          </div>
          <GraphicalIcon icon="graphic-mentoring-header" />
        </div>
        {isFirstTimeOnTrack ? (
          <div className="question">
            <h3>What are you hoping to learn from this track?</h3>
            <p>
              Tell our mentors a little about your programming background and
              what you’re aiming to learn from {track.title}.
            </p>
            <textarea required />
          </div>
        ) : null}
        <div className="question">
          <h3>How can a mentor help you with this solution?</h3>
          <p>
            Give your mentor a starting point for the conversation. This will be
            your first comment on during the session.
          </p>
          <textarea required />
        </div>
        <button className="btn-cta">Submit mentoring request</button>
        <p className="flow-explanation">
          Once you submit, your request will be open for a mentor to join and
          start providing feedback. The recent median wait time is ~
          {track.medianWaitTime}
        </p>
      </div>
    </div>
  )
}
