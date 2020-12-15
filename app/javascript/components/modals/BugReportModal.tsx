import React, { useRef, useState, useCallback, useEffect } from 'react'
import Modal from 'react-modal'
import { useRequest } from '../../hooks/use-request'
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

      setStatus(BugReportModalStatus.SENDING)

      controllerRef.current?.abort()
      controllerRef.current = undefined

      const [request, cancel] = useRequest(
        url,
        JSON.stringify({ bug_report: { body: e.target.elements.body.value } }),
        'POST'
      )

      controllerRef.current = cancel

      return request
        .then((json: any) => {
          if (!isMountedRef.current) {
            throw new Error('Component not mounted')
          }

          setStatus(BugReportModalStatus.SUCCEEDED)

          return json
        })
        .catch((err) => {
          if (err.message === 'Component not mounted') {
            return
          }

          throw err
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
    <Modal isOpen={open} onRequestClose={onClose}>
      <Status status={status} />
      <form onSubmit={handleSubmit}>
        <label htmlFor="body">Report</label>
        <textarea id="body"></textarea>
        <button type="submit" disabled={!url}>
          Submit
        </button>
      </form>
    </Modal>
  )
}
