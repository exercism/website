import React, { useContext } from 'react'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { SenioritySurveyModalContext } from './SenioritySurveyModal'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export function ThanksView() {
  const { patchCloseModal } = useContext(SenioritySurveyModalContext)

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
        status={patchCloseModal.status}
        className="btn-primary btn-l"
        type="button"
        onClick={patchCloseModal.mutate}
      >
        Close this modal
      </FormButton>
      <ErrorBoundary resetKeys={[patchCloseModal.status]}>
        <ErrorMessage
          error={patchCloseModal.status}
          defaultError={DEFAULT_ERROR}
        />
      </ErrorBoundary>
    </div>
  )
}
