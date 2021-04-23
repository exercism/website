import React, { useState, useCallback } from 'react'
import { MentorDiscussion } from '../../../types'
import { Avatar, GraphicalIcon } from '../../../common'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { FormButton } from '../../../common'
import { FetchingBoundary } from '../../../FetchingBoundary'

type Links = {
  finish: string
}

const DEFAULT_ERROR = new Error('Unable to submit mentor rating')

export const AddTestimonialStep = ({
  onSubmit,
  onBack,
  links,
  discussion,
}: {
  onSubmit: () => void
  onBack: () => void
  links: Links
  discussion: MentorDiscussion
}): JSX.Element => {
  const [value, setValue] = useState('')
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation(
    () => {
      return sendRequest({
        endpoint: links.finish,
        method: 'PATCH',
        body: JSON.stringify({
          rating: 'happy',
          testimonial: value,
        }),
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: onSubmit,
    }
  )
  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()
      mutation()
    },
    [mutation]
  )
  const handleBack = useCallback(() => {
    onBack()
  }, [onBack])
  const handleChange = useCallback((e) => {
    setValue(e.target.value)
  }, [])
  const primaryButtonText = value.length === 0 ? 'Skip' : 'Finish'
  const primaryButtonClass = value.length === 0 ? 'btn' : 'btn-cta'

  return (
    <section className="testimonial-step">
      <div className="container">
        <div className="lhs">
          <h2>Say thanks to {discussion.mentor.handle}!</h2>
          <div className="celebration">
            <p>
              <strong>That’s awesome!</strong> 🙂 We’re glad you had a good
              session with {discussion.mentor.handle}.
            </p>
          </div>
          <p className="explanation">
            Mentors volunteer their time for free. A nice testimonial is a great
            way of thanking them, and encouraging them to continue helping
            others.
          </p>
          <form onSubmit={handleSubmit}>
            <label htmlFor="testimonial">
              Leave {discussion.mentor.handle} a testimonial (optional)
            </label>
            <textarea
              value={value}
              onChange={handleChange}
              id="testimonial"
              placeholder="Write your testimonial here"
            />
            {/*<p className="help">
              Testimonials are a place to write what impressed you about a
              mentor.
              <br />
              Mentors can choose to display them on their profiles.
            </p>*/}
            <div className="form-buttons">
              <FormButton
                type="button"
                onClick={handleBack}
                status={status}
                className="btn"
              >
                <GraphicalIcon icon="arrow-left" />
                <span>Back</span>
              </FormButton>

              <FormButton
                type="submit"
                status={status}
                className={primaryButtonClass}
              >
                <span>{primaryButtonText}</span>
              </FormButton>
            </div>
          </form>
          <FetchingBoundary
            status={status}
            error={error}
            defaultError={DEFAULT_ERROR}
          />
        </div>
        <div className="rhs">
          <div className="avatar-wrapper">
            <Avatar
              src={discussion.mentor.avatarUrl}
              handle={discussion.mentor.handle}
            />
            {value.length !== 0 ? (
              <GraphicalIcon icon="thumb-up-white-on-green" />
            ) : null}
          </div>
        </div>
      </div>
    </section>
  )
}
