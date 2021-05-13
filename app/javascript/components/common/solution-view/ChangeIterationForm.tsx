import React, { useState, useCallback } from 'react'
import { Iteration, SolutionForStudent } from '../../types'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { useMutation } from 'react-query'
import { IterationSelector } from './IterationSelector'
import { FormButton } from '../FormButton'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to change published iteration')

export const ChangeIterationForm = ({
  endpoint,
  defaultIterationIdx,
  iterations,
  onCancel,
}: {
  endpoint: string
  defaultIterationIdx: number | null
  iterations: readonly Iteration[]
  onCancel: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [iterationIdx, setIterationIdx] = useState<number | null>(
    defaultIterationIdx
  )
  const [mutation, { status, error }] = useMutation<SolutionForStudent>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({ published_iteration_idx: iterationIdx }),
        isMountedRef: isMountedRef,
      }).then((response) => {
        return typecheck<SolutionForStudent>(response, 'solution')
      })
    },
    {
      onSuccess: (solution) => {
        window.location.replace(solution.publicUrl)
      },
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form onSubmit={handleSubmit}>
      <IterationSelector
        iterationIdx={iterationIdx}
        setIterationIdx={setIterationIdx}
        iterations={iterations}
      />
      <FormButton type="submit" status={status}>
        Submit
      </FormButton>
      <FormButton type="button" onClick={onCancel} status={status}>
        Cancel
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </form>
  )
}
