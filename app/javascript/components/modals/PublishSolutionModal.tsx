import React, { useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { Iteration, SolutionForStudent } from '@/components/types'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils/redirect-to'
import { typecheck } from '@/utils/typecheck'
import { FormButton } from '@/components/common/FormButton'
import { ErrorMessage, ErrorBoundary } from '@/components/ErrorBoundary'
import { ModalProps, Modal } from './Modal'
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
  const [iterationIdx, setIterationIdx] = useState<number | null>(null)
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<SolutionForStudent>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({ iteration_idx: iterationIdx }),
      })

      return fetch.then((json) =>
        typecheck<SolutionForStudent>(json, 'solution')
      )
    },
    {
      onSuccess: (solution) => {
        redirectTo(solution.privateUrl)
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
      <form data-turbo="false" onSubmit={handleSubmit}>
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
