import React, { useState, useCallback, useEffect, useRef } from 'react'
import { sendRequest } from '../../utils/send-request'
import { Modal } from './Modal'
import { useMutation } from 'react-query'

enum BugReportModalStatus {
  INITIALIZED = 'initialized',
  SENDING = 'sending',
  SUCCEEDED = 'succeeded',
}

const Status = ({ status }: { status: BugReportModalStatus }) => {
  switch (status) {
    case BugReportModalStatus.SUCCEEDED:
      return <p>Thanks for submitting a bug report</p>
    case BugReportModalStatus.SENDING:
      return <p>Sending report...</p>
    default:
      return null
  }
}

export const BugReportModal = ({
  open,
  onClose,
  ...props
}: {
  open: boolean
  onClose: () => void
}): JSX.Element => {
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
    <Modal
      open={open}
      onClose={onClose}
      className="modal-bug-report"
      {...props}
    >
      <Status status={status} />
      <form onSubmit={handleSubmit}>
        <label htmlFor="content_markdown">Report</label>
        <textarea id="content_markdown" ref={textareaRef}></textarea>
        <button type="submit" disabled={!url}>
          Submit
        </button>
      </form>
    </Modal>
  )
}
