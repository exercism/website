import React from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { ExerciseDiff } from '../ExerciseUpdateModal'
import { useIsMounted } from 'use-is-mounted'
import { FormButton } from '../../common/FormButton'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'
import { SolutionForStudent } from '../../types'
import { typecheck } from '../../../utils/typecheck'

const DEFAULT_ERROR = new Error('Unable to update exercise')

export const ExerciseUpdateForm = ({
  diff,
  onCancel,
}: {
  diff: ExerciseDiff
  onCancel: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()

  const [mutation, { status, error }] = useMutation<SolutionForStudent>(
    () => {
      return sendRequest({
        endpoint: diff.links.update,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        return typecheck<SolutionForStudent>(json, 'solution')
      })
    },
    {
      onSuccess: (solution) => {
        window.location.replace(solution.privateUrl)
      },
    }
  )

  return (
    <form>
      <FormButton type="button" onClick={() => mutation()} status={status}>
        Update exercise
      </FormButton>
      <FormButton type="button" onClick={onCancel} status={status}>
        Dismiss
      </FormButton>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </form>
  )
}
