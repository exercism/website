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
import { generateAriaFieldIds } from '@/utils/generate-aria-field-ids'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const PublishSolutionModal = ({
  endpoint,
  iterations,
  ...props
}: ModalProps & {
  endpoint: string
  iterations: readonly Iteration[]
}): JSX.Element => {
  const [iterationIdx, setIterationIdx] = useState<number | null>(null)
  const { t } = useAppTranslation()

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<SolutionForStudent>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: JSON.stringify({ iteration_idx: iterationIdx }),
      })

      return fetch.then((json) =>
        typecheck<SolutionForStudent>(json, 'solution')
      )
    },
    onSuccess: (solution) => {
      redirectTo(solution.privateUrl)
    },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const ariaObject = generateAriaFieldIds('publish-solution')
  return (
    <Modal
      {...props}
      aria={ariaObject}
      className="m-change-published-iteration"
    >
      <form data-turbo="false" onSubmit={handleSubmit}>
        <h3 id={ariaObject.labelledby}>
          {t('publishSolutionModal.publishYourSolution')}
        </h3>
        <p id={ariaObject.describedby}>
          {t('publishSolutionModal.recommendPublishing')}
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
            {t('publishSolutionModal.publish')}
          </FormButton>
          <FormButton
            type="button"
            onClick={props.onClose}
            status={status}
            className="btn-default btn-m"
          >
            {t('publishSolutionModal.cancel')}
          </FormButton>
        </div>
        <ErrorBoundary>
          <ErrorMessage
            error={error}
            defaultError={
              new Error(t('publishSolutionModal.unableToPublishSolution'))
            }
          />
        </ErrorBoundary>
      </form>
    </Modal>
  )
}
