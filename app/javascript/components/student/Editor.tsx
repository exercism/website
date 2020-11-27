import React, {
  useReducer,
  useRef,
  useEffect,
  useCallback,
  createRef,
} from 'react'
import { TestRunSummary } from './editor/TestRunSummary'
import { Submitting } from './editor/Submitting'
import { FileEditor, FileEditorHandle } from './editor/FileEditor'
import { fetchJSON } from '../../utils/fetch-json'
import { typecheck } from '../../utils/typecheck'
import { Submission, TestRun, TestRunStatus, File } from './editor/types'
import { Iteration } from '../track/IterationSummary'
import { useIsMounted } from 'use-is-mounted'
import { camelizeKeys } from 'humps'

type APIError = {
  type: string
  message: string
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
  apiError?: APIError
}

enum ActionType {
  CREATING_SUBMISSION = 'creatingSubmission',
  SUBMISSION_CREATED = 'submissionCreated',
  CREATING_ITERATION = 'creatingIteration',
  SUBMISSION_CANCELLED = 'submissionCancelled',
  SUBMISSION_CHANGED = 'submissionChanged',
}

type EditorRef = {
  file: File
  ref: React.RefObject<FileEditorHandle>
}

type Action =
  | { type: ActionType.CREATING_SUBMISSION }
  | {
      type: ActionType.SUBMISSION_CREATED
      payload: { submission: Submission }
    }
  | { type: ActionType.SUBMISSION_CANCELLED; payload?: { apiError?: APIError } }
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
        apiError: undefined,
        submission: undefined,
        status: EditorStatus.CREATING_SUBMISSION,
      }
    case ActionType.SUBMISSION_CREATED:
      return {
        ...state,
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
        status: EditorStatus.SUBMISSION_CREATED,
      }
    case ActionType.SUBMISSION_CANCELLED:
      return {
        ...state,
        apiError: action.payload?.apiError,
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

export function Editor({
  endpoint,
  timeout = 60000,
  initialSubmission,
  files,
  language,
}: {
  endpoint: string
  timeout?: number
  initialSubmission?: Submission
  files: File[]
  language: string
}) {
  const isMountedRef = useIsMounted()
  const [{ submission, status, apiError }, dispatch] = useReducer(reducer, {
    status: undefined,
    submission: initialSubmission,
  })
  const controllerRef = useRef<AbortController | undefined>(
    new AbortController()
  )
  const editorsRef = useRef<EditorRef[]>(
    files.map((file) => {
      return { file: file, ref: createRef<FileEditorHandle>() } as EditorRef
    })
  )
  const abort = useCallback(() => {
    controllerRef.current?.abort()
    controllerRef.current = undefined
  }, [controllerRef])
  const runTests = useCallback(() => {
    const files = editorsRef.current.map((editor) => {
      return editor.ref.current?.getFile()
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
        if (!isMountedRef.current) {
          return
        }

        dispatch({
          type: ActionType.SUBMISSION_CREATED,
          payload: { submission: typecheck<Submission>(json, 'submission') },
        })

        editorsRef.current = files.map((file) => {
          return {
            file: file,
            ref: createRef<FileEditorHandle>(),
          } as EditorRef
        })
      })
      .catch((err) => {
        if (!isMountedRef.current) {
          return
        }

        if (err instanceof Error) {
          if (err.name === 'AbortError' && controllerRef.current) {
            return
          }
          dispatch({ type: ActionType.SUBMISSION_CANCELLED })
        }

        if (err instanceof Response) {
          err.json().then((res: any) =>
            dispatch({
              type: ActionType.SUBMISSION_CANCELLED,
              payload: { apiError: res.error },
            })
          )
        }
      })
      .finally(() => {
        controllerRef.current = undefined
      })
  }, [abort, controllerRef, isMountedRef])
  const submit = useCallback(
    (e: React.MouseEvent<HTMLButtonElement>) => {
      if (!submission) {
        return
      }

      controllerRef.current = new AbortController()

      dispatch({ type: ActionType.CREATING_ITERATION })

      fetchJSON(submission.links.submit, {
        method: 'POST',
        body: JSON.stringify({}),
        signal: controllerRef.current.signal,
      })
        .then((json: any) => {
          if (!isMountedRef.current) {
            return
          }

          const iteration = typecheck<Iteration>(json, 'iteration')
          location.assign(iteration.links.self)
        })
        .catch((err) => {
          if (!isMountedRef.current) {
            return
          }

          if (err instanceof Error) {
            if (err.name === 'AbortError' && controllerRef.current) {
              return
            }
          }
        })
        .finally(() => {
          controllerRef.current = undefined
        })
    },
    [controllerRef, isMountedRef, submission]
  )
  const cancel = useCallback(() => {
    abort()
    dispatch({ type: ActionType.SUBMISSION_CANCELLED })
  }, [dispatch, abort])
  const updateSubmission = useCallback(
    (testRun: TestRun) => {
      if (!isMountedRef.current) {
        return
      }

      dispatch({
        type: ActionType.SUBMISSION_CHANGED,
        payload: { testRun: testRun },
      })
    },
    [dispatch, isMountedRef]
  )

  useEffect(() => {
    return abort
  }, [abort])

  useEffect(() => {
    if (!submission) {
      return
    }

    controllerRef.current = new AbortController()

    fetchJSON(submission.links.testRun, {
      method: 'GET',
      signal: controllerRef.current.signal,
    })
      .then((json: any) => {
        if (!isMountedRef.current) {
          return
        }
        updateSubmission(typecheck<TestRun>(camelizeKeys(json), 'testRun'))
      })
      .catch((err) => {
        if (!isMountedRef.current) {
          return
        }

        if (err instanceof Error) {
          if (err.name === 'AbortError' && controllerRef.current) {
            return
          }
        }
      })
      .finally(() => {
        controllerRef.current = undefined
      })
  }, [])

  return (
    <div>
      {editorsRef.current.map((editor) => (
        <FileEditor
          key={editor.file.filename}
          file={editor.file}
          ref={editor.ref}
          language={language}
          onRunTests={runTests}
        />
      ))}
      <button
        type="button"
        onClick={() => {
          runTests()
        }}
      >
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
      {apiError && <p>{apiError.message}</p>}
      {submission && submission.testRun && (
        <TestRunSummary
          testRun={submission.testRun}
          cancelLink={submission.links.cancel}
          timeout={timeout}
          onUpdate={updateSubmission}
        />
      )}
    </div>
  )
}
