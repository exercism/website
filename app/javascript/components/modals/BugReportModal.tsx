import React, { useState, useCallback, useEffect } from 'react'
import { sendRequest } from '../../utils/send-request'
import { Modal } from './Modal'
import { useMutation } from '@tanstack/react-query'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  url = document.querySelector<HTMLMetaElement>('meta[name="bug-reports-url"]')
    ?.content,
  minLength = 5,
  ...props
}: {
  open: boolean
  onClose: () => void
  trackSlug?: string
  exerciseSlug?: string
  url?: string
  minLength?: number
}): JSX.Element => {
  const [status, setStatus] = useState(BugReportModalStatus.INITIALIZED)
  const [content, setContent] = useState('')

  const { t } = useAppTranslation('components/modals/BugReportModal.tsx')

  const { mutate: mutation } = useMutation({
    mutationFn: async () => {
      if (!url) {
        throw 'No bug report URL found'
      }

      const { fetch } = sendRequest({
        endpoint: url,
        method: 'POST',
        body: JSON.stringify({
          bug_report: {
            content_markdown: content,
            track_slug: trackSlug,
            exercise_slug: exerciseSlug,
          },
        }),
      })

      return fetch
    },
    onSuccess: () => {
      setStatus(BugReportModalStatus.SUCCEEDED)
    },
  })
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

  const handleChange = useCallback((e) => {
    setContent(e.target.value)
  }, [])

  const handleClose = useCallback(() => {
    onClose()
  }, [onClose])

  useEffect(() => {
    if (!open) {
      return
    }

    setStatus(BugReportModalStatus.INITIALIZED)
  }, [open])

  const isFormDisabled = !url || content.length < minLength

  return (
    <Modal open={open} onClose={onClose} className="m-bug-report" {...props}>
      <h3>{t('reportABug')}</h3>

      {status == BugReportModalStatus.SUCCEEDED ? (
        <>
          <p>{t('bugReportSubmittedThankYou')}</p>
          <div className="buttons">
            <button
              type="button"
              className="btn-enhanced btn-s"
              onClick={handleClose}
            >
              {t('close')}
            </button>
          </div>
        </>
      ) : (
        <form data-turbo="false" onSubmit={handleSubmit}>
          <label htmlFor="content_markdown">
            {t('thanksForReportingPleaseTellUsWhatIsWrong')}
          </label>
          <textarea
            id="content_markdown"
            value={content}
            onChange={handleChange}
            placeholder={t('pleaseProvideAsMuchDetailAsPossible')}
            minLength={minLength}
          />
          <div className="buttons">
            <button
              type="submit"
              disabled={isFormDisabled}
              className="btn-primary btn-s"
            >
              {t('submitBugReport')}
            </button>
            <button
              type="button"
              className="btn-enhanced btn-s"
              onClick={handleClose}
            >
              {t('cancel')}
            </button>
          </div>
        </form>
      )}
    </Modal>
  )
}
