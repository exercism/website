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
  SUBMITTING = 'submitting',
  SUBMITTED = 'submitted',
  SUBMISSION_CANCELLED = 'submissionCancelled',
}

type State = {
  submission?: Submission
  status?: EditorStatus
}

type Action =
  | { type: EditorStatus.SUBMITTING }
  | { type: EditorStatus.SUBMITTED; payload: { submission: Submission } }
  | { type: EditorStatus.SUBMISSION_CANCELLED }

function reducer(state: State, action: Action) {
  switch (action.type) {
    case EditorStatus.SUBMITTING:
      return {
        ...state,
        submission: undefined,
        status: EditorStatus.SUBMITTING,
      }
    case EditorStatus.SUBMITTED:
      return {
        ...state,
        status: EditorStatus.SUBMITTED,
        submission: action.payload.submission,
      }
    case EditorStatus.SUBMISSION_CANCELLED:
      return {
        ...state,
        status: EditorStatus.SUBMISSION_CANCELLED,
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
  const [{ submission, status }, dispatch] = useReducer(reducer, {
    status: undefined,
    submission: undefined,
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

      dispatch({ type: EditorStatus.SUBMITTING })

      fetchJSON(endpoint, {
        method: 'POST',
        signal: controllerRef.current.signal,
        body: JSON.stringify({ files: { file: code } }),
      })
        .then((json: any) => {
          dispatch({
            type: EditorStatus.SUBMITTED,
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
      {status === EditorStatus.SUBMITTING && <Submitting onCancel={cancel} />}
      {submission && (
        <TestRunSummary submission={submission} timeout={timeout} />
      )}
    </div>
  )
}
