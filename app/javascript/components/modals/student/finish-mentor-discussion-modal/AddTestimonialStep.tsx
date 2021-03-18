import React, { useCallback, useRef } from 'react'
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
  const isMountedRef = useIsMounted()
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const [mutation] = useMutation(
    () => {
      return sendRequest({
        endpoint: links.finish,
        method: 'POST',
        body: JSON.stringify({
          rating: 'happy',
          testimonial: textareaRef.current?.value,
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

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <label htmlFor="testimonial">Testimonial</label>
        <textarea ref={textareaRef} id="testimonial" />
        <button type="submit">Submit testimonial</button>
      </form>
      <button type="button" onClick={handleBack}>
        Back
      </button>
    </div>
  )
}
