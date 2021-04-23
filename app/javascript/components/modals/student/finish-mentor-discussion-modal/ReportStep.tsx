import React, { useCallback, useState, useRef } from 'react'
import { MentorDiscussion } from '../../../types'
import { Avatar, GraphicalIcon } from '../../../common'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { FormButton } from '../../../common'
import { FetchingBoundary } from '../../../FetchingBoundary'

type Links = {
  finish: string
}

const DEFAULT_ERROR = new Error('Unable to submit mentor rating')

export const ReportStep = ({
  links,
  onSubmit,
  onBack,
  discussion,
}: {
  links: Links
  onSubmit: () => void
  onBack: () => void
  discussion: MentorDiscussion
}): JSX.Element => {
  const [state, setState] = useState({ requeue: true, report: false })
  const reasonRef = useRef<HTMLSelectElement>(null)
  const messageRef = useRef<HTMLTextAreaElement>(null)
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation(
    () => {
      return sendRequest({
        endpoint: links.finish,
        method: 'PATCH',
        body: JSON.stringify({
          rating: 1,
          requeue: state.requeue,
          report: state.report,
          report_reason: reasonRef.current?.value,
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

  const handleBack = useCallback(() => {
    onBack()
  }, [onBack])

  return (
    <section className="report-step">
      <div className="container">
        <div className="lhs">
          <h2>How can we help?</h2>
          <p className="explanation">
            We’re really sorry that you experienced a problematic mentoring
            discussion, and would like to help ensure your next experience is a
            positive one.
          </p>
          <form onSubmit={handleSubmit}>
            <h3>How would you like to resolve the issue?</h3>

            <label className="c-checkbox-wrapper">
              <input type="checkbox" checked={true} disabled={true} />
              <div className="row">
                <div className="c-checkbox">
                  <GraphicalIcon icon="checkmark" />
                </div>
                Block further interactions with this mentor
              </div>
            </label>
            <label htmlFor="requeue" className="c-checkbox-wrapper">
              <input
                type="checkbox"
                checked={state.requeue}
                onChange={() => setState({ ...state, requeue: !state.requeue })}
                id="requeue"
              />
              <div className="row">
                <div className="c-checkbox">
                  <GraphicalIcon icon="checkmark" />
                </div>
                Put your solution back in the queue for mentoring
              </div>
            </label>
            <label htmlFor="report" className="c-checkbox-wrapper">
              <input
                type="checkbox"
                checked={state.report}
                onChange={() => setState({ ...state, report: !state.report })}
                id="report"
              />
              <div className="row">
                <div className="c-checkbox">
                  <GraphicalIcon icon="checkmark" />
                </div>
                Report this discussion to an admin
              </div>
            </label>

            {state.report ? (
              <div className="report">
                <div className="field">
                  <label htmlFor="reason">
                    Why are you reporting this conversation?
                  </label>
                  <div className="c-select">
                    <select ref={reasonRef} id="reason">
                      <option value="coc">Code of Conduct violation</option>
                      <option value="incorrect">
                        Wrong or misleading information
                      </option>
                      <option value="other">Other</option>
                    </select>
                  </div>
                </div>

                <div className="field">
                  <label htmlFor="message">What went wrong?</label>
                  <textarea
                    required
                    ref={messageRef}
                    id="message"
                    placeholder="Please provide exactly why you are making this report, and tell us what happened."
                  />
                </div>
                <div className="assurance">
                  Your report will be sent to our adminstrators who will
                  investigate further
                </div>
              </div>
            ) : null}

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
              <FormButton status={status} type="submit" className="btn-cta">
                Finish
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
          <Avatar
            src={discussion.mentor.avatarUrl}
            handle={discussion.mentor.handle}
          />
        </div>
      </div>
    </section>
  )
}
