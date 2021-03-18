import React, { useState, useCallback } from 'react'
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
}: {
  onSubmit: () => void
  onBack: () => void
  links: Links
}): JSX.Element => {
  const [value, setValue] = useState('')
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation(
    () => {
      return sendRequest({
        endpoint: links.finish,
        method: 'POST',
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
  const buttonText =
    value.length === 0 ? 'Skip testimonial' : 'Submit testimonial'

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <label htmlFor="testimonial">Testimonial</label>
        <textarea value={value} onChange={handleChange} id="testimonial" />
        <FormButton type="submit" status={status}>
          {buttonText}
        </FormButton>
        {value.length !== 0 ? 'Thumbs up' : null}
      </form>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      />
      <FormButton type="button" onClick={handleBack} status={status}>
        Back
      </FormButton>
    </div>
  )
}
