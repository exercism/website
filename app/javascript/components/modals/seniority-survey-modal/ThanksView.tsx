import React, { useContext, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { sendRequest } from '@/utils/send-request'
import { SenioritySurveyModalContext } from './SenioritySurveyModal'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export function ThanksView() {
  const { links, setOpen } = useContext(SenioritySurveyModalContext)

  const {
    mutate: hideModalMutation,
    status: hideModalMutationStatus,
    error: hideModalMutationError,
  } = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: links.hideModalEndpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: () => {
        setOpen(false)
      },
    }
  )

  const handleSave = useCallback(() => {
    hideModalMutation()
  }, [hideModalMutation])
  return (
    <div className="lhs">
      <header>
        <h1>Thanks for letting us know!</h1>
        <p>
          We'll use this information to make sure you're seeing the most
          relevant content.
        </p>
      </header>

      <FormButton
        status={hideModalMutationStatus}
        className="btn-primary btn-l"
        type="button"
        onClick={handleSave}
      >
        Close this modal
      </FormButton>
      <ErrorBoundary resetKeys={[hideModalMutationStatus]}>
        <ErrorMessage
          error={hideModalMutationError}
          defaultError={DEFAULT_ERROR}
        />
      </ErrorBoundary>
    </div>
  )
}
