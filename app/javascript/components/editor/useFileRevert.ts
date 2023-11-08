import { sendRequest } from '../../utils/send-request'
import { Submission } from './types'
import { File } from '../types'
import { useMutation } from '@tanstack/react-query'
import { typecheck } from '../../utils/typecheck'

export const useFileRevert = () => {
  const { mutate: revertToLastIteration } = useMutation<
    File[],
    unknown,
    Submission
  >(async (submission) => {
    if (!submission) {
      throw 'Submission expected'
    }

    const { fetch } = sendRequest({
      endpoint: submission.links.lastIterationFiles,
      body: null,
      method: 'GET',
    })

    return fetch.then((json) => typecheck<File[]>(json, 'files'))
  })

  const { mutate: revertToExerciseStart } = useMutation<
    File[],
    unknown,
    Submission
  >(async (submission) => {
    if (!submission) {
      throw 'Submission expected'
    }

    const { fetch } = sendRequest({
      endpoint: submission.links.initialFiles,
      body: null,
      method: 'GET',
    })

    return fetch.then((json) => typecheck<File[]>(json, 'files'))
  })

  return { revertToExerciseStart, revertToLastIteration }
}
