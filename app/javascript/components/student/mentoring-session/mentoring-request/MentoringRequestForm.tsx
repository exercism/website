import React, { useRef } from 'react'
import {
  CopyToClipboardButton,
  FormButton,
  GraphicalIcon,
} from '../../../common'
import { Track, Exercise } from '../../MentoringSession'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { typecheck } from '../../../../utils/typecheck'
import { useIsMounted } from 'use-is-mounted'
import { MentoringRequest } from '../../../types'
import { FetchingBoundary } from '../../../FetchingBoundary'

type Links = {
  learnMoreAboutPrivateMentoring: string
  privateMentoring: string
  mentoringGuide: string
  createMentorRequest: string
}

const DEFAULT_ERROR = new Error('Unable to create mentor request')

export const MentoringRequestForm = ({
  isFirstTimeOnTrack,
  track,
  exercise,
  links,
  onSuccess,
}: {
  isFirstTimeOnTrack: boolean
  track: Track
  exercise: Exercise
  links: Links
  onSuccess: (mentorRequest: MentoringRequest) => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<
    MentoringRequest | undefined
  >(
    () => {
      return sendRequest({
        endpoint: links.createMentorRequest,
        method: 'POST',
        body: JSON.stringify({ comment: solutionCommentRef.current?.value }),
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<MentoringRequest>(json, 'mentorRequest')
      })
    },
    {
      onSuccess: (mentorRequest) => {
        if (!mentorRequest) {
          return
        }

        onSuccess(mentorRequest)
      },
    }
  )

  const trackCommentRef = useRef<HTMLTextAreaElement>(null)
  const solutionCommentRef = useRef<HTMLTextAreaElement>(null)

  return (
    <div className="mentoring-request-section">
      <div className="direct">
        <h3>
          Send this link to a friend for private mentoring.{' '}
          <a href={links.learnMoreAboutPrivateMentoring}>Learn more</a>.
        </h3>
        <CopyToClipboardButton textToCopy={links.privateMentoring} />
      </div>
      <form className="community" onSubmit={() => mutation()}>
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
            {/*TODO: @iHiD Instead of an h3, I made this a label */}
            <label htmlFor="track-comment">
              What are you hoping to learn from this track?
            </label>
            <p>
              Tell our mentors a little about your programming background and
              what you’re aiming to learn from {track.title}.
            </p>
            <textarea ref={trackCommentRef} id="track-comment" required />
          </div>
        ) : null}
        <div className="question">
          {/*TODO: @iHiD Instead of an h3, I made this a label */}
          <label htmlFor="solution-comment">
            How can a mentor help you with this solution?
          </label>
          <p>
            Give your mentor a starting point for the conversation. This will be
            your first comment on during the session.
          </p>
          <textarea ref={solutionCommentRef} id="solution-comment" required />
        </div>
        <FormButton status={status} className="btn-cta">
          Submit mentoring request
        </FormButton>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        ></FetchingBoundary>
        <p className="flow-explanation">
          Once you submit, your request will be open for a mentor to join and
          start providing feedback. The recent median wait time is ~
          {track.medianWaitTime}
        </p>
      </form>
    </div>
  )
}
