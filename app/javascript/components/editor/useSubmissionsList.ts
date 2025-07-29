import { useState, useEffect, useCallback } from 'react'
import { sendRequest } from '../../utils/send-request'
import { Submission, TestRunStatus, TestRun } from './types'
import { File, SubmissionTestsStatus } from '../types'
import { useMutation } from '@tanstack/react-query'
import { typecheck } from '../../utils/typecheck'

type Links = {
  create: string
}

type CreateSubmissionParams = {
  files: File[]
  testResults: Object | null
}

export const useSubmissionsList = (
  defaultList: readonly Submission[],
  links: Links
): {
  current: Submission | null
  create: (
    params: CreateSubmissionParams,
    config?: { onSuccess: () => void; onError: (error: unknown) => void }
  ) => void
  set: (uuid: string, data: Submission) => void
  remove: (uuid: string) => void
} => {
  const [list, setList] = useState(defaultList)

  const { mutate: create } = useMutation<
    Submission,
    unknown,
    CreateSubmissionParams
  >({
    mutationFn: async ({ files, testResults }) => {
      const testResultsJson = testResults ? JSON.stringify(testResults) : null
      const nonReadonlyFiles = files.filter(
        (file) => file.type !== 'readonly' && file.type !== 'legacy'
      )
      appendFaux()
      const { fetch } = sendRequest({
        endpoint: links.create,
        method: 'POST',
        body: JSON.stringify({
          files: nonReadonlyFiles,
          test_results_json: testResultsJson,
        }),
      })
      return fetch.then((response) =>
        typecheck<Submission>(response, 'submission')
      )
    },
    onSuccess: (submission) => {
      setList([
        ...list.filter((s) => s.uuid !== 'faux-submission'),
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

    onError: () => {
      setList((prevList) => {
        return prevList.filter((s) => s.uuid !== 'faux-submission')
      })
    },
  })

  const set = useCallback(
    (uuid: string, data: Submission) => {
      setList((prevList) => prevList.map((s) => (s.uuid === uuid ? data : s)))
    },
    [setList]
  )

  // append a faux submission at the moment someone clicks "Run Tests"
  // to force the UI into the "Running tests" state
  const appendFaux = useCallback(() => {
    const fauxSubmission: Submission = {
      testsStatus: SubmissionTestsStatus.NOT_QUEUED,
      uuid: 'faux-submission',
      links: {
        cancel: '',
        submit: '',
        testRun: '',
        aiHelp: '',
        initialFiles: '',
        lastIterationFiles: '',
      },
    }

    setList((prev) => [
      ...prev,
      {
        ...fauxSubmission,
        testRun: {
          uuid: null,
          submissionUuid: fauxSubmission.uuid,
          version: 0,
          status: TestRunStatus.QUEUED,
          tests: [],
          message: '',
          messageHtml: '',
          output: '',
          outputHtml: '',
          highlightjsLanguage: '',
          links: {
            self: '',
          },
          tasks: [],
        },
      },
    ])
  }, [setList])

  const remove = useCallback(
    (uuid: string) => {
      setList((list) => list.filter((s) => s.uuid !== uuid))
    },
    [setList]
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
  }, [set])

  return { current, create, set, remove }
}
