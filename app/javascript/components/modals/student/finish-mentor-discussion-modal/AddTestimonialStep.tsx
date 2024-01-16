import React, { useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { MentorDiscussion } from '@/components/types'
import { Avatar, GraphicalIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { TestimonialField } from './TestimonialField'

const DEFAULT_ERROR = new Error('Unable to submit mentor rating')

export const AddTestimonialStep = ({
  onSubmit,
  onSkip,
  onBack,
  discussion,
}: {
  onSubmit: () => void
  onSkip: () => void
  onBack: () => void
  discussion: MentorDiscussion
}): JSX.Element => {
  const [value, setValue] = useState('')
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation(
    async () => {
      const { fetch } = sendRequest({
        endpoint: discussion.links.finish,
        method: 'PATCH',
        body: JSON.stringify({
          rating: 5,
          testimonial: value,
        }),
      })

      return fetch
    },
    {
      onSuccess: () => {
        value.length === 0 ? onSkip() : onSubmit()
      },
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
  const primaryButtonClass =
    value.length === 0 ? 'btn-default btn-m' : 'btn-primary btn-m'

  return (
    <section className="testimonial-step">
      <h2>We&apos;re glad you had a good discussion!</h2>
      <div className="container">
        <div className="lhs">
          <p className="explanation">
            Mentors volunteer their time for free. A nice testimonial is a great
            way of thanking them, and encouraging them to continue helping
            others.
          </p>
          <form data-turbo="false" onSubmit={handleSubmit}>
            <label htmlFor="testimonial">
              Leave {discussion.mentor.handle} a testimonial (optional)
            </label>
            <TestimonialField
              id="testimonial"
              min={30}
              max={160}
              value={value}
              onChange={handleChange}
            />
            <div className="form-buttons">
              <FormButton
                type="button"
                onClick={handleBack}
                status={status}
                className="btn-default btn-m"
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
