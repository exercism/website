import React, { useState, useCallback } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'

type Links = {
  finish: string
}

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
  const [mutation] = useMutation(
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
        <button type="submit">{buttonText}</button>
        {value.length !== 0 ? 'Thumbs up' : null}
      </form>
      <button type="button" onClick={handleBack}>
        Back
      </button>
    </div>
  )
}
