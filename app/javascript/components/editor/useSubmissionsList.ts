import { useState, useEffect, useCallback } from 'react'
import { sendRequest } from '../../utils/send-request'
import { Submission, TestRunStatus, TestRun } from './types'
import { File } from '../types'
import { useMutation } from '@tanstack/react-query'
import { typecheck } from '../../utils/typecheck'

type Links = {
  create: string
}

export const useSubmissionsList = (
  defaultList: readonly Submission[],
  links: Links
): {
  current: Submission | null
  create: (
    files: File[],
    config?: { onSuccess: () => void; onError: (error: unknown) => void }
  ) => void
  set: (uuid: string, data: Submission) => void
  remove: (uuid: string) => void
} => {
  const [list, setList] = useState(defaultList)

  const { mutate: create } = useMutation<Submission, unknown, File[]>(
    async (files) => {
      const { fetch } = sendRequest({
        endpoint: links.create,
        method: 'POST',
        body: JSON.stringify({ files: files }),
      })

      return fetch.then((response) =>
        typecheck<Submission>(response, 'submission')
      )
    },
    {
      onSuccess: (submission) => {
        setList([
          ...list,
          {
            ...submission,
            testRun: {
              uuid: null,
              submissionUuid: submission.uuid,
              version: 0,
              status: TestRunStatus.QUEUED,
              tests: [],
              message: '',
              messageHtml: '',
              output: '',
              outputHtml: '',
              highlightjsLanguage: '',
              links: {
                self: submission.links.testRun,
              },
              tasks: [],
            },
          },
        ])
      },
    }
  )

  const set = useCallback(
    (uuid: string, data: Submission) => {
      setList(list.map((s) => (s.uuid === uuid ? data : s)))
    },
    [JSON.stringify(list)]
  )

  const remove = useCallback(
    (uuid: string) => {
      setList(list.filter((s) => s.uuid !== uuid))
    },
    [JSON.stringify(list)]
  )

  const current = list[list.length - 1] || null

  useEffect(() => {
    if (defaultList.length === 0) {
      return
    }

    if (current.testRun) {
      return
    }

    const { fetch } = sendRequest({
      endpoint: current.links.testRun,
      body: null,
      method: 'GET',
    })

    fetch.then((json) => {
      const testRun = typecheck<TestRun>(json, 'testRun')

      set(current.uuid, { ...current, testRun: testRun })
    })
  }, [JSON.stringify(defaultList), set])

  return { current, create, set, remove }
}
