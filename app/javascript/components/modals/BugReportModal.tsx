import React, { useRef, useState, useCallback, useEffect } from 'react'
import Modal from 'react-modal'
import { sendPostRequest } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'

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
  const [status, setStatus] = useState(BugReportModalStatus.INITIALIZED)
  const url = document.querySelector<HTMLMetaElement>(
    'meta[name="bug-reports-url"]'
  )?.content
  const controllerRef = useRef<AbortController | undefined>(
    new AbortController()
  )
  const isMountedRef = useIsMounted()
  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()
      if (!url) {
        return
      }

      return sendPostRequest({
        endpoint: url,
        body: {
          bug_report: {
            content_markdown: e.target.elements.content_markdown.value,
          },
        },
        isMountedRef: isMountedRef,
      })
        .then((json: any) => {
          if (!json) {
            return
          }

          setStatus(BugReportModalStatus.SUCCEEDED)
        })
        .finally(() => {
          controllerRef.current = undefined
        })
    },
    [isMountedRef, url]
  )

  useEffect(() => {
    if (!open) {
      return
    }

    setStatus(BugReportModalStatus.INITIALIZED)
  }, [open])

  return (
    <Modal isOpen={open} onRequestClose={onClose} {...props}>
      <Status status={status} />
      <form onSubmit={handleSubmit}>
        <label htmlFor="content_markdown">Report</label>
        <textarea id="content_markdown"></textarea>
        <button type="submit" disabled={!url}>
          Submit
        </button>
      </form>
    </Modal>
  )
}
