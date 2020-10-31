import React, { useReducer, useRef, useEffect, useCallback } from 'react'
import { TestRunSummary } from './editor/TestRunSummary'
import { Submitting } from './editor/Submitting'
import { FileEditor, FileEditorHandle } from './editor/FileEditor'
import { fetchJSON } from '../../utils/fetch-json'
import { typecheck } from '../../utils/typecheck'
import { Iteration } from '../track/IterationSummary'

export type Submission = {
  testsStatus: SubmissionTestsStatus
  uuid: string
  links: SubmissionLinks
  testRun: TestRun
}

export enum SubmissionTestsStatus {
  NOT_QUEUED = 'not_queued',
  QUEUED = 'queued',
  PASSED = 'passed',
  FAILED = 'failed',
  ERRORED = 'errored',
  EXCEPTIONED = 'exceptioned',
  CANCELLED = 'cancelled',
}

export type TestRun = {
  id: number | null
  submissionUuid: string
  status: TestRunStatus
  message: string
  tests: Test[]
}

export type Test = {
  name: string
  status: TestStatus
  message: string
  output: string
}

export enum TestStatus {
  PASS = 'pass',
  FAIL = 'fail',
  ERROR = 'error',
}

type SubmissionLinks = {
  cancel: string
  submit: string
}

export enum TestRunStatus {
  PASS = 'pass',
  FAIL = 'fail',
  ERROR = 'error',
  OPS_ERROR = 'ops_error',
  QUEUED = 'queued',
  TIMEOUT = 'timeout',
  CANCELLING = 'cancelling',
  CANCELLED = 'cancelled',
}

enum EditorStatus {
  CREATING_SUBMISSION = 'creatingSubmission',
  SUBMISSION_CREATED = 'submissionCreated',
  CREATING_ITERATION = 'creatingIteration',
  SUBMISSION_CANCELLED = 'submissionCancelled',
}

type State = {
  submission?: Submission
  status?: EditorStatus
}

enum ActionType {
  CREATING_SUBMISSION = 'creatingSubmission',
  SUBMISSION_CREATED = 'submissionCreated',
  CREATING_ITERATION = 'creatingIteration',
  SUBMISSION_CANCELLED = 'submissionCancelled',
  SUBMISSION_CHANGED = 'submissionChanged',
}

type Action =
  | { type: ActionType.CREATING_SUBMISSION }
  | {
      type: ActionType.SUBMISSION_CREATED
      payload: { submission: Submission }
    }
  | { type: ActionType.SUBMISSION_CANCELLED }
  | { type: ActionType.CREATING_ITERATION }
  | {
      type: ActionType.SUBMISSION_CHANGED
      payload: { testRun: TestRun }
    }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case ActionType.CREATING_SUBMISSION:
      return {
        ...state,
        submission: undefined,
        status: EditorStatus.CREATING_SUBMISSION,
      }
    case ActionType.SUBMISSION_CREATED:
      return {
        ...state,
        status: EditorStatus.SUBMISSION_CREATED,
        submission: {
          ...action.payload.submission,
          testRun: {
            id: null,
            submissionUuid: action.payload.submission.uuid,
            status: TestRunStatus.QUEUED,
            tests: [],
            message: '',
          },
        },
      }
    case ActionType.SUBMISSION_CANCELLED:
      return {
        ...state,
        status: EditorStatus.SUBMISSION_CANCELLED,
      }
    case ActionType.CREATING_ITERATION:
      return {
        ...state,
        status: EditorStatus.CREATING_ITERATION,
      }
    case ActionType.SUBMISSION_CHANGED:
      return {
        ...state,
        submission: {
          ...(state.submission as Submission),
          testRun: action.payload.testRun,
        },
      }
    default:
      return state
  }
}

export type File = {
  filename: string
  content: string
}

export function Editor({
  endpoint,
  timeout = 60000,
  initialSubmission,
  files,
}: {
  endpoint: string
  timeout?: number
  initialSubmission?: Submission
  files: File[]
}) {
  const [{ submission, status }, dispatch] = useReducer(reducer, {
    status: undefined,
    submission: initialSubmission,
  })
  const controllerRef = useRef<AbortController | undefined>(
    new AbortController()
  )
  const editorsRef = useRef<FileEditorHandle[]>([])
  const abort = useCallback(() => {
    controllerRef.current?.abort()
    controllerRef.current = undefined
  }, [controllerRef])
  const runTests = useCallback(
    (e: React.MouseEvent<HTMLButtonElement>) => {
      const files = editorsRef.current.map((editor) => {
        return editor.getFile()
      })

      abort()
      controllerRef.current = new AbortController()

      dispatch({ type: ActionType.CREATING_SUBMISSION })

      fetchJSON(endpoint, {
        method: 'POST',
        signal: controllerRef.current.signal,
        body: JSON.stringify({ files: files }),
      })
        .then((json: any) => {
          dispatch({
            type: ActionType.SUBMISSION_CREATED,
            payload: { submission: typecheck<Submission>(json, 'submission') },
          })
        })
        .catch((err) => {
          if (err.name === 'AbortError' && controllerRef.current) {
            return
          }

          dispatch({ type: ActionType.SUBMISSION_CANCELLED })
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

      dispatch({ type: ActionType.CREATING_ITERATION })

      fetchJSON(submission.links.submit, {
        method: 'POST',
        body: JSON.stringify({}),
      }).then((json: any) => {
        const iteration = typecheck<Iteration>(json, 'iteration')
        location.assign(iteration.links.self)
      })
    },
    [submission]
  )
  const cancel = useCallback(() => {
    abort()
    dispatch({ type: ActionType.SUBMISSION_CANCELLED })
  }, [dispatch, abort])
  const updateSubmission = useCallback(
    (testRun: TestRun) => {
      dispatch({
        type: ActionType.SUBMISSION_CHANGED,
        payload: { testRun: testRun },
      })
    },
    [dispatch]
  )

  useEffect(() => {
    return abort
  }, [abort])

  return (
    <div>
      {files.map((file) => (
        <FileEditor
          key={file.filename}
          file={file}
          ref={(ref) => {
            if (ref) {
              editorsRef.current.push(ref)
            }
          }}
        />
      ))}
      <button type="button" onClick={runTests}>
        Run tests
      </button>
      <button
        type="button"
        onClick={submit}
        disabled={submission?.testRun?.status !== TestRunStatus.PASS}
      >
        Submit
      </button>
      {status === EditorStatus.CREATING_SUBMISSION && (
        <Submitting onCancel={cancel} />
      )}
      {status === EditorStatus.CREATING_ITERATION && <p>Submitting...</p>}
      {submission && submission.testRun && (
        <TestRunSummary
          cancelLink={submission.links.cancel}
          testRun={submission.testRun}
          timeout={timeout}
          onUpdate={updateSubmission}
        />
      )}
    </div>
  )
}
