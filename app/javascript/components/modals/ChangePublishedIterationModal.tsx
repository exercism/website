import React, { useState, useCallback } from 'react'
import { useMutation } from 'react-query'
import { ModalProps, Modal } from './Modal'
import { redirectTo } from '@/utils/redirect-to'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { Iteration, SolutionForStudent } from '@/components/types'
import { FormButton } from '@/components/common/FormButton'
import { ErrorMessage, ErrorBoundary } from '@/components/ErrorBoundary'
import { IterationSelector } from './student/IterationSelector'

const DEFAULT_ERROR = new Error('Unable to change published iteration')
export type RedirectType = 'public' | 'private'

export const ChangePublishedIterationModal = ({
  endpoint,
  redirectType,
  defaultIterationIdx,
  iterations,
  ...props
}: ModalProps & {
  endpoint: string
  redirectType: RedirectType
  defaultIterationIdx: number | null
  iterations: readonly Iteration[]
}): JSX.Element => {
  const [iterationIdx, setIterationIdx] = useState<number | null>(
    defaultIterationIdx
  )
  const [mutation, { status, error }] = useMutation<SolutionForStudent>(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({ published_iteration_idx: iterationIdx }),
      })

      return fetch.then((response) =>
        typecheck<SolutionForStudent>(response, 'solution')
      )
    },
    {
      onSuccess: (solution) => {
        if (redirectType == 'public') {
          redirectTo(solution.publicUrl)
        } else {
          redirectTo(solution.privateUrl)
        }
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
      <h3>Change published iterations</h3>
      <p>
        We recommend publishing all iterations to help others learn from your
        journey, but you can also choose just your favourite iteration to
        showcase instead.
      </p>
      <form data-turbo="false" onSubmit={handleSubmit}>
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
            Update published solution
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
