import React, { useCallback, useState, useRef } from 'react'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'

type Links = {
  finish: string
}

export const ReportStep = ({
  links,
  onSubmit,
}: {
  links: Links
  onSubmit: () => void
}): JSX.Element => {
  const [state, setState] = useState({ requeue: true, report: false })
  const messageRef = useRef<HTMLTextAreaElement>(null)
  const isMountedRef = useIsMounted()
  const [mutation] = useMutation(
    () => {
      return sendRequest({
        endpoint: links.finish,
        method: 'POST',
        body: JSON.stringify({
          rating: 'unhappy',
          requeue: state.requeue,
          report: state.report,
          report_message: messageRef.current?.value,
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

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="checkbox"
        checked={state.requeue}
        onChange={() => setState({ ...state, requeue: !state.requeue })}
        id="requeue"
      />
      <label htmlFor="requeue">
        Put your solution back in the queue for mentoring
      </label>
      <input
        type="checkbox"
        checked={state.report}
        onChange={() => setState({ ...state, report: !state.report })}
        id="report"
      />
      <label htmlFor="report">Report this discussion to an admin</label>
      {state.report ? (
        <React.Fragment>
          <label htmlFor="message">Message</label>
          <textarea ref={messageRef} id="message" />
        </React.Fragment>
      ) : null}
      <button type="submit">Submit</button>
    </form>
  )
}
