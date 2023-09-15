import { sendRequest } from '../../utils/send-request'
import { UseMutateFunction, useMutation } from '@tanstack/react-query'
import { typecheck } from '../../utils/typecheck'
import { Submission } from './types'
import { Iteration } from '../types'

export const useIteration = (): {
  create: UseMutateFunction<Iteration, unknown, Submission, unknown>
} => {
  const { mutate: create } = useMutation<Iteration, unknown, Submission>(
    async (submission) => {
      if (!submission) {
        throw 'Expected submission'
      }

      const { fetch } = sendRequest({
        endpoint: submission.links.submit,
        method: 'POST',
        body: null,
      })

      return fetch.then((json) => typecheck<Iteration>(json, 'iteration'))
    }
  )

  return { create }
}
