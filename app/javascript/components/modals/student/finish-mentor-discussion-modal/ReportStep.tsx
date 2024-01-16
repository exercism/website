import React, { useCallback, useState, useRef } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { MentorDiscussion } from '@/components/types'
import { Avatar, GraphicalIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { MentorReport } from '../FinishMentorDiscussionModal'
import { ReasonSelect } from './ReasonSelect'

const DEFAULT_ERROR = new Error('Unable to submit mentor rating')

export const ReportStep = ({
  discussion,
  onSubmit,
  onBack,
  send,
}: {
  onSubmit: (report: MentorReport) => void
  onBack: () => void
  discussion: MentorDiscussion
  send: (step: string) => void
}): JSX.Element => {
  const [state, setState] = useState<MentorReport>({
    requeue: true,
    report: false,
    reason: 'coc',
  })

  const messageRef = useRef<HTMLTextAreaElement>(null)
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
          rating: 1,
          requeue: state.requeue,
          report: state.report,
          report_reason: state.reason,
          report_message: messageRef.current?.value,
        }),
      })

      return fetch
    },
    {
      onSuccess: () => {
        onSubmit(state)
      },
      onError: (e) => {
        console.error('Error running mutation in ReportStep.tsx', e)
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

  return (
    <section className="report-step">
      <h2>How can we help?</h2>
      <div className="container">
        <div className="lhs">
          <p className="explanation">
            We’re really sorry that you experienced a problematic mentoring
            discussion, and would like to help ensure your next experience is a
            positive one.
          </p>
          <form data-turbo="false" onSubmit={handleSubmit}>
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
                  <ReasonSelect
                    value={state.reason}
                    setValue={(reason) =>
                      setState({ ...state, reason: reason })
                    }
                  />
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
                className="btn-default btn-m"
              >
                <GraphicalIcon icon="arrow-left" />
                <span>Back</span>
              </FormButton>
              <FormButton
                status={status}
                type="submit"
                className="btn-primary btn-m"
              >
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
