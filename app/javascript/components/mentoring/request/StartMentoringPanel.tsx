import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { MentorSessionRequest as Request } from '../../types'
import { Loading } from '../../common'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to lock solution')

const ErrorMessage = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return <p>{error.message}</p>
}

export const StartMentoringPanel = ({
  request,
  onLock,
}: {
  request: Request
  onLock: (request: Request) => void
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/mentoring/request/StartMentoringPanel.tsx'
  )
  const {
    mutate: lock,
    status,
    error,
  } = useMutation<Request>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: request.links.lock,
        body: null,
        method: 'PATCH',
      })

      return fetch.then((json) => typecheck<Request>(json, 'request'))
    },
    onSuccess: (request) => onLock(request),
  })

  return (
    <section className="comment-section --lock">
      <h2>
        {t('startMentoringPanel.helpStudentWriteBetter', {
          studentHandle: request.student.handle,
          trackTitle: request.track.title,
        })}
      </h2>
      <p>
        {t('startMentoringPanel.showThemWayToCodeBliss', {
          studentHandle: request.student.handle,
        })}
      </p>
      <button
        type="button"
        onClick={() => lock()}
        disabled={status === 'pending'}
        className="btn-primary btn-m"
      >
        {t('startMentoringPanel.startMentoring')}
      </button>
      <div className="note">
        {t('startMentoringPanel.sessionReturnsToQueue')}
      </div>
      {status === 'pending' ? <Loading /> : null}
      <ErrorBoundary FallbackComponent={ErrorFallback} resetKeys={[status]}>
        <ErrorMessage
          error={
            error
              ? new Error(t('startMentoringPanel.unableToLockSolution'))
              : null
          }
        />
      </ErrorBoundary>
    </section>
  )
}
