import React, { useState, useCallback } from 'react'
import { ModalProps, Modal } from './Modal'
import { Iteration, SolutionForStudent } from '../types'
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
  const [mutation, { status, error }] = useMutation<SolutionForStudent>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({ iteration_idx: iterationIdx }),
        isMountedRef: isMountedRef,
      }).then((response) => {
        return typecheck<SolutionForStudent>(response, 'solution')
      })
    },
    {
      onSuccess: (solution) => {
        window.location.replace(solution.privateUrl)
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
    <Modal {...props} className="m-change-published-iteration">
      <form onSubmit={handleSubmit}>
        <h3>Publish your solution</h3>
        <p>
          We recommend publishing all iterations to help others learn from your
          journey, but you can also choose just your favourite iteration to
          showcase instead.
        </p>
        <IterationSelector
          iterationIdx={iterationIdx}
          setIterationIdx={setIterationIdx}
          iterations={iterations}
        />
        <div className="btns">
          <FormButton
            type="submit"
            status={status}
            className="btn-primary btn-m"
          >
            Publish
          </FormButton>
          <FormButton
            type="button"
            onClick={props.onClose}
            status={status}
            className="btn-default btn-m"
          >
            Cancel
          </FormButton>
        </div>
        <ErrorBoundary>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
