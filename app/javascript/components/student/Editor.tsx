import React, { useReducer, useRef, useEffect, useCallback } from 'react'
import { CodeEditor } from './editor/CodeEditor'
import { TestRunSummary } from './editor/TestRunSummary'
import { Submitting } from './editor/Submitting'
import { fetchJSON } from '../../utils/fetch-json'
import { typecheck } from '../../utils/typecheck'

export type Submission = {
  testsStatus: TestRunStatus
  uuid: string
}

export enum TestRunStatus {
  PASS = 'pass',
  FAIL = 'fail',
  ERROR = 'error',
  PENDING = 'pending',
  OPS_ERROR = 'ops_error',
}

type State = {
  submission?: Submission
  isSubmitting: boolean
  code: string
}

export type Action =
  | { type: 'submitting'; payload: { code: string } }
  | { type: 'submitted'; payload: { submission: Submission } }
  | { type: 'submissionCancelled' }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'submitting':
      return {
        submission: undefined,
        code: action.payload.code,
        isSubmitting: true,
      }
    case 'submitted':
      return {
        ...state,
        submission: action.payload.submission,
        isSubmitting: false,
      }
    case 'submissionCancelled':
      return {
        ...state,
        isSubmitting: false,
      }
    default:
      return state
  }
}

export function Editor({
  endpoint,
  timeout = 60000,
}: {
  endpoint: string
  timeout?: number
}) {
  const [{ submission, isSubmitting, code }, dispatch] = useReducer(reducer, {
    submission: undefined,
    isSubmitting: false,
    code: '',
  })
  const controllerRef = useRef(new AbortController())
  const abortFetch = useCallback(() => {
    controllerRef.current.abort()
    controllerRef.current = new AbortController()
  }, [controllerRef.current])

  useEffect(() => {
    return () => {
      abortFetch()
    }
  }, [])

  useEffect(() => {
    if (isSubmitting) {
      return
    }

    abortFetch()
  }, [isSubmitting])

  useEffect(() => {
    if (code === '') {
      return
    }

    if (isSubmitting) {
      abortFetch()
    }

    fetchJSON(endpoint, {
      method: 'POST',
      signal: controllerRef.current.signal,
      body: JSON.stringify({ files: { file: code } }),
    })
      .then((json: any) => {
        dispatch({
          type: 'submitted',
          payload: { submission: typecheck<Submission>(json, 'submission') },
        })
      })
      .catch((responseOrError) => {
        if (responseOrError.name === 'AbortError') {
          console.log('Fetch cancelled')
        }
      })
  }, [code])

  return (
    <div>
      <CodeEditor dispatch={dispatch} />
      {isSubmitting && <Submitting dispatch={dispatch} />}
      {submission && (
        <TestRunSummary submission={submission} timeout={timeout} />
      )}
    </div>
  )
}
