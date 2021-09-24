import React, { useState, useCallback, useEffect, useRef } from 'react'
import { sendRequest } from '../../utils/send-request'
import { Modal } from './Modal'
import { useMutation } from 'react-query'

enum BugReportModalStatus {
  INITIALIZED = 'initialized',
  SENDING = 'sending',
  SUCCEEDED = 'succeeded',
}

export const BugReportModal = ({
  open,
  onClose,
  trackSlug,
  exerciseSlug,
  ...props
}: {
  open: boolean
  onClose: () => void
  trackSlug?: string
  exerciseSlug?: string
}): JSX.Element => {
  const handleClose = useCallback(() => {
    onClose()
  }, [onClose])

  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const [status, setStatus] = useState(BugReportModalStatus.INITIALIZED)
  const url = document.querySelector<HTMLMetaElement>(
    'meta[name="bug-reports-url"]'
  )?.content
  const [mutation] = useMutation(
    () => {
      if (!url) {
        throw 'No bug report URL found'
      }

      const { fetch } = sendRequest({
        endpoint: url,
        method: 'POST',
        body: JSON.stringify({
          bug_report: {
            content_markdown: textareaRef.current?.value,
            track_slug: trackSlug,
            exercise_slug: exerciseSlug,
          },
        }),
      })

      return fetch
    },
    {
      onSuccess: () => {
        setStatus(BugReportModalStatus.SUCCEEDED)
      },
    }
  )
  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      if (!url) {
        return
      }

      mutation()
    },
    [url, mutation]
  )

  useEffect(() => {
    if (!open) {
      return
    }

    setStatus(BugReportModalStatus.INITIALIZED)
  }, [open])

  return (
    <Modal open={open} onClose={onClose} className="m-bug-report" {...props}>
      <h3>Report a bug</h3>

      {status == BugReportModalStatus.SUCCEEDED ? (
        <>
          <p>Bug report submitted. Thank you!</p>
          <div className="buttons">
            <button
              type="button"
              className="btn-enhanced btn-s"
              onClick={handleClose}
            >
              Close
            </button>
          </div>
        </>
      ) : (
        <form data-turbo="false" onSubmit={handleSubmit}>
          <label htmlFor="content_markdown">
            Thanks for reporting. Please tell is what is wrong.
          </label>
          <textarea
            id="content_markdown"
            ref={textareaRef}
            placeholder="Please provide as much detail as possible"
          ></textarea>
          <div className="buttons">
            <button type="submit" disabled={!url} className="btn-primary btn-s">
              Submit bug report
            </button>
            <button
              type="button"
              className="btn-enhanced btn-s"
              onClick={handleClose}
            >
              Cancel
            </button>
          </div>
        </form>
      )}
    </Modal>
  )
}
