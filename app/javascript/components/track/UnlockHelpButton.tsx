import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { GraphicalIcon } from '../common'
import { ErrorBoundary, useErrorHandler } from '../ErrorBoundary'

export function UnlockHelpButton({
  unlockUrl,
}: {
  unlockUrl: string
}): JSX.Element {
  function UnlockHelp() {
    const { fetch } = sendRequest({
      endpoint: unlockUrl,
      body: '',
      method: 'PATCH',
    })
    return fetch
  }

  const DEFAULT_ERROR = new Error(
    'There was an error unlocking help, please try again!'
  )

  const ErrorMessage = ({ error }: { error: unknown }) => {
    useErrorHandler(error, { defaultError: DEFAULT_ERROR })

    return null
  }

  const ErrorFallback = ({ error }: { error: Error }) => {
    return (
      <div
        style={{ padding: '8px 16px' }}
        className="c-alert--danger_dark text-15 font-body mt-10 normal-case"
      >
        {error.message}
      </div>
    )
  }

  const { mutate: unlockHelp, error } = useMutation(UnlockHelp, {
    onSuccess: () => window.location.reload(),
  })

  return (
    <div className="flex flex-col mb-10">
      <button
        style={{
          height: 'unset',
          boxShadow: '0px 2px 4px rgba(var(--shadowColorMain), 0.15)',
        }}
        className="btn-primary btn-s flex items-center grow text-14 leading-170 py-8"
        onClick={() => unlockHelp()}
      >
        <GraphicalIcon icon="unlock" width={14} height={14} className="mr-8" />
        Unlock this tab
      </button>

      <ErrorBoundary FallbackComponent={ErrorFallback}>
        <ErrorMessage error={error} />
      </ErrorBoundary>
    </div>
  )
}

export default UnlockHelpButton
