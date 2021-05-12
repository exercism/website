import React, { useState, useCallback } from 'react'
import { ModalProps, Modal } from './Modal'
import { Iteration, Exercise } from '../types'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { typecheck } from '../../utils/typecheck'
import { useIsMounted } from 'use-is-mounted'
import { FormButton } from '../common'
import { ErrorMessage, ErrorBoundary } from '../ErrorBoundary'
import { IterationSelector } from './student/IterationSelector'

const DEFAULT_ERROR = new Error('Unable to publish solution')

export const PublishSolutionModal = ({
  endpoint,
  iterations,
  ...props
}: ModalProps & {
  endpoint: string
  iterations: readonly Iteration[]
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [iterationIdx, setIterationIdx] = useState<number | null>(null)
  const [mutation, { status, error }] = useMutation<Exercise>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({ iteration_idx: iterationIdx }),
        isMountedRef: isMountedRef,
      }).then((response) => {
        return typecheck<Exercise>(response, 'exercise')
      })
    },
    {
      onSuccess: (exercise) => {
        if (!exercise.isUnlocked) {
          throw new Error('Expected to redirect to exercise')
        }

        window.location.replace(exercise.links.self)
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
    <Modal {...props}>
      <form onSubmit={handleSubmit}>
        <IterationSelector
          iterationIdx={iterationIdx}
          setIterationIdx={setIterationIdx}
          iterations={iterations}
        />
        <FormButton type="submit" status={status}>
          Submit
        </FormButton>
        <FormButton type="button" onClick={props.onClose} status={status}>
          Cancel
        </FormButton>
        <ErrorBoundary>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
