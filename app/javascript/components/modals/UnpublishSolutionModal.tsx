import React from 'react'
import { Modal, ModalProps } from './Modal'
import { useIsMounted } from 'use-is-mounted'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { typecheck } from '../../utils/typecheck'
import { Exercise } from '../types'
import { FormButton } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to unpublish solution')

export const UnpublishSolutionModal = ({
  endpoint,
  ...props
}: ModalProps & { endpoint: string }): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<Exercise>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        return typecheck<Exercise>(json, 'exercise')
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

  return (
    <Modal {...props}>
      <FormButton type="button" onClick={props.onClose} status={status}>
        Cancel
      </FormButton>
      <FormButton type="button" onClick={() => mutation()} status={status}>
        Confirm
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
