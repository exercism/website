import React, { useReducer, useRef, useEffect, useCallback } from 'react'
import { TestRunSummary } from './editor/TestRunSummary'
import { Submitting } from './editor/Submitting'
import { fetchJSON } from '../../utils/fetch-json'
import { typecheck } from '../../utils/typecheck'
import MonacoEditor from 'react-monaco-editor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'

export type Submission = {
  testsStatus: TestRunStatus
  uuid: string
  links: SubmissionLinks
}

type SubmissionLinks = {
  cancel: string
  submit: string
}

export enum TestRunStatus {
  PASS = 'pass',
  FAIL = 'fail',
  ERROR = 'error',
  QUEUED = 'queued',
  OPS_ERROR = 'ops_error',
  TIMEOUT = 'timeout',
  CANCELLING = 'cancelling',
  CANCELLED = 'cancelled',
}

enum EditorStatus {
  CREATING_SUBMISSION = 'creatingSubmission',
  SUBMISSION_CREATED = 'submissionCreated',
  ITERATION_CREATED = 'iterationCreated',
  CREATING_ITERATION = 'creatingIteration',
  SUBMISSION_CANCELLED = 'submissionCancelled',
}

type State = {
  submission?: Submission
  status?: EditorStatus
}

type Action =
  | { type: EditorStatus.CREATING_SUBMISSION }
  | {
      type: EditorStatus.SUBMISSION_CREATED
      payload: { submission: Submission }
    }
  | { type: EditorStatus.SUBMISSION_CANCELLED }
  | { type: EditorStatus.ITERATION_CREATED }
  | { type: EditorStatus.CREATING_ITERATION }

function reducer(state: State, action: Action) {
  switch (action.type) {
    case EditorStatus.CREATING_SUBMISSION:
      return {
        ...state,
        submission: undefined,
        status: EditorStatus.CREATING_SUBMISSION,
      }
    case EditorStatus.SUBMISSION_CREATED:
      return {
        ...state,
        status: EditorStatus.SUBMISSION_CREATED,
        submission: action.payload.submission,
      }
    case EditorStatus.SUBMISSION_CANCELLED:
      return {
        ...state,
        status: EditorStatus.SUBMISSION_CANCELLED,
      }
    case EditorStatus.ITERATION_CREATED:
      return {
        ...state,
        status: EditorStatus.ITERATION_CREATED,
      }
    case EditorStatus.CREATING_ITERATION:
      return {
        ...state,
        status: EditorStatus.CREATING_ITERATION,
      }
    default:
      return state
  }
}

export function Editor({
  endpoint,
  timeout = 60000,
  initialSubmission,
}: {
  endpoint: string
  timeout?: number
  initialSubmission?: Submission
}) {
  const [{ submission, status }, dispatch] = useReducer(reducer, {
    status: undefined,
    submission: initialSubmission,
  })
  const editorRef = useRef<monacoEditor.editor.IStandaloneCodeEditor>()
  const controllerRef = useRef<AbortController | undefined>(
    new AbortController()
  )
  const abort = useCallback(() => {
    controllerRef.current?.abort()
    controllerRef.current = undefined
  }, [controllerRef])
  const runTests = useCallback(
    (e: React.MouseEvent<HTMLButtonElement>) => {
      const code = editorRef.current?.getValue() || ''

      if (code.trim().length === 0) {
        return
      }

      abort()
      controllerRef.current = new AbortController()

      dispatch({ type: EditorStatus.CREATING_SUBMISSION })

      fetchJSON(endpoint, {
        method: 'POST',
        signal: controllerRef.current.signal,
        body: JSON.stringify({ files: { file: code } }),
      })
        .then((json: any) => {
          dispatch({
            type: EditorStatus.SUBMISSION_CREATED,
            payload: { submission: typecheck<Submission>(json, 'submission') },
          })
        })
        .catch((err) => {
          if (err.name === 'AbortError' && controllerRef.current) {
            return
          }

          dispatch({ type: EditorStatus.SUBMISSION_CANCELLED })
        })
        .finally(() => {
          controllerRef.current = undefined
        })
    },
    [abort, controllerRef]
  )
  const submit = useCallback(
    (e: React.MouseEvent<HTMLButtonElement>) => {
      if (!submission) {
        return
      }

      dispatch({ type: EditorStatus.CREATING_ITERATION })

      fetchJSON(submission.links.submit, { method: 'POST' }).then(
        (json: any) => {
          dispatch({ type: EditorStatus.ITERATION_CREATED })
        }
      )
    },
    [submission]
  )
  const cancel = useCallback(() => {
    abort()
    dispatch({ type: EditorStatus.SUBMISSION_CANCELLED })
  }, [dispatch, abort])
  const editorDidMount = useCallback(
    (editor) => {
      editorRef.current = editor
    },
    [editorRef]
  )

  useEffect(() => {
    return abort
  }, [abort])

  return (
    <div>
      <MonacoEditor
        width="800"
        height="600"
        language="ruby"
        editorDidMount={editorDidMount}
        defaultValue="Code"
      />
      <button type="button" onClick={runTests}>
        Run tests
      </button>
      <button type="button" onClick={submit}>
        Submit
      </button>
      {status === EditorStatus.CREATING_SUBMISSION && (
        <Submitting onCancel={cancel} />
      )}
      {status === EditorStatus.CREATING_ITERATION && <p>Submitting...</p>}
      {status === EditorStatus.ITERATION_CREATED && <p>Iteration submitted</p>}
      {submission && (
        <TestRunSummary submission={submission} timeout={timeout} />
      )}
    </div>
  )
}
