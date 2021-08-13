import React from 'react'
import { QueryStatus } from 'react-query'
import { FormButton } from '../../common'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'

export const MutationButton = ({
  onClick,
  disabled,
  mutation,
  defaultError,
}: {
  onClick: () => void
  disabled: boolean
  mutation: { status: QueryStatus; error: unknown }
  defaultError: Error
}): JSX.Element => {
  return (
    <React.Fragment>
      <FormButton
        type="button"
        onClick={onClick}
        disabled={disabled}
        status={mutation.status}
      >
        Mark as read
      </FormButton>
      <ErrorBoundary resetKeys={[mutation.status]}>
        <ErrorMessage error={mutation.error} defaultError={defaultError} />
      </ErrorBoundary>
    </React.Fragment>
  )
}
