import React, {
  useRef,
  useEffect,
  useCallback,
  useState,
  createContext,
} from 'react'
import { typecheck } from '../utils/typecheck'
import {
  Submission,
  TestRun,
  TestRunStatus,
  Keybindings,
  WrapSetting,
  Themes,
  Assignment,
} from './editor/types'
import { File } from './types'
import { Iteration } from './types'
import { Header } from './editor/Header'
import { FileEditor, FileEditorHandle } from './editor/FileEditor'
import { InstructionsPanel } from './editor/InstructionsPanel'
import { TestsPanel } from './editor/TestsPanel'
import { ResultsPanel } from './editor/ResultsPanel'
import { InstructionsTab } from './editor/InstructionsTab'
import { TestsTab } from './editor/TestsTab'
import { ResultsTab } from './editor/ResultsTab'
import { EditorStatusSummary } from './editor/EditorStatusSummary'
import { RunTestsButton } from './editor/RunTestsButton'
import { SubmitButton } from './editor/SubmitButton'
import { useIsMounted } from 'use-is-mounted'
import { camelizeKeys } from 'humps'
import { useSaveFiles } from './editor/useSaveFiles'
import {
  useSubmission,
  ActionType as SubmissionActionType,
  SubmissionStatus,
} from './editor/useSubmission'
import { useFileRevert, RevertStatus } from './editor/useFileRevert'
import { isEqual } from 'lodash'
import { sendRequest, sendPostRequest, APIError } from '../utils/send-request'
import { TabContext } from './common/Tab'
import { StoredScrollPanel } from './editor/StoredScrollPanel'

export type TabIndex = 'instructions' | 'tests' | 'results'

export enum EditorStatus {
  INITIALIZED = 'initialized',
  CREATING_SUBMISSION = 'creatingSubmission',
  SUBMISSION_CREATED = 'submissionCreated',
  CREATING_ITERATION = 'creatingIteration',
  SUBMISSION_CANCELLED = 'submissionCancelled',
  REVERTING_TO_EXERCISE_START = 'revertingToExerciseStart',
  REVERTED = 'reverted',
  REVERT_FAILED = 'revertFailed',
}

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export function Editor({
  endpoint,
  timeout = 60000,
  initialSubmission,
  files: initialFiles,
  language,
  exercisePath,
  trackTitle,
  exerciseTitle,
  introduction,
  assignment,
  exampleFiles,
  storageKey,
  debuggingInstructions,
}: {
  endpoint: string
  timeout?: number
  initialSubmission?: Submission
  files: File[]
  language: string
  exercisePath: string
  trackTitle: string
  exerciseTitle: string
  introduction: string
  assignment: Assignment
  exampleFiles: File[]
  storageKey: string
  debuggingInstructions?: string
}) {
  const [tab, setTab] = useState<TabIndex>('instructions')
  const [theme, setTheme] = useState(Themes.LIGHT)
  const [
    { status: revertStatus, apiError: revertApiError },
    revertDispatch,
  ] = useFileRevert()
  const [apiError, setApiError] = useState<APIError | null>(null)
  const editorRef = useRef<FileEditorHandle>()
  const keyboardShortcutsRef = useRef<HTMLButtonElement>(null)
  const submissionFilesRef = useRef<File[]>(initialFiles)
  const [files] = useSaveFiles(storageKey, initialFiles, () => {
    return editorRef.current?.getFiles() || []
  })
  const [keybindings, setKeybindings] = useState<Keybindings>(
    Keybindings.DEFAULT
  )
  const [wrap, setWrap] = useState<WrapSetting>('on')
  const isMountedRef = useIsMounted()
  const [
    { submission, status: submissionStatus, apiError: submissionApiError },
    submissionDispatch,
  ] = useSubmission(initialSubmission)
  const [status, setStatus] = useState(EditorStatus.INITIALIZED)
  const controllerRef = useRef<AbortController | undefined>(
    new AbortController()
  )
  const abort = useCallback(() => {
    controllerRef.current?.abort()
    controllerRef.current = undefined
  }, [controllerRef])

  const runTests = useCallback(() => {
    const files = editorRef.current?.getFiles()

    if (!files) {
      return
    }

    submissionDispatch({ type: SubmissionActionType.CREATING_SUBMISSION })

    abort()
    sendPostRequest({
      endpoint: endpoint,
      body: { files: files },
      isMountedRef: isMountedRef,
    })
      .then((json: any) => {
        if (!json) {
          return
        }

        submissionDispatch({
          type: SubmissionActionType.SUBMISSION_CREATED,
          payload: {
            submission: typecheck<Submission>(json, 'submission'),
          },
        })
        setTab('results')
        submissionFilesRef.current = files
      })
      .catch((err) => {
        if (err instanceof Error) {
          submissionDispatch({
            type: SubmissionActionType.SUBMISSION_CANCELLED,
          })
        }

        if (err instanceof Response) {
          err.json().then((res: any) => {
            submissionDispatch({
              type: SubmissionActionType.SUBMISSION_CANCELLED,
              payload: { apiError: res.error },
            })
          })
        }
      })
      .finally(() => {
        controllerRef.current = undefined
      })
  }, [submissionDispatch, endpoint, isMountedRef])

  const submit = useCallback(() => {
    if (!submission) {
      return
    }

    if (submission.testRun?.status !== TestRunStatus.PASS) {
      return
    }

    submissionDispatch({ type: SubmissionActionType.CREATING_ITERATION })

    abort()
    sendPostRequest({
      endpoint: submission.links.submit,
      body: {},
      isMountedRef: isMountedRef,
    })
      .then((json: any) => {
        if (!json) {
          return
        }

        const iteration = typecheck<Iteration>(json, 'iteration')
        location.assign(iteration.links.solution)
      })
      .finally(() => {
        controllerRef.current = undefined
      })
  }, [submission, submissionDispatch, isMountedRef])

  const cancel = useCallback(() => {
    abort()
    submissionDispatch({ type: SubmissionActionType.SUBMISSION_CANCELLED })
  }, [submissionDispatch, abort])

  const updateSubmission = useCallback(
    (testRun: TestRun) => {
      submissionDispatch({
        type: SubmissionActionType.SUBMISSION_CHANGED,
        payload: { testRun: testRun },
      })
    },
    [submissionDispatch]
  )
  const editorDidMount = useCallback(
    (editor) => {
      editorRef.current = editor
    },
    [editorRef]
  )

  const isSubmitDisabled =
    submission?.testRun?.status !== TestRunStatus.PASS ||
    !isEqual(submissionFilesRef.current, files)

  useEffect(() => {
    return abort
  }, [abort])

  useEffect(() => {
    if (!initialSubmission) {
      return
    }

    abort()
    sendRequest({
      endpoint: initialSubmission.links.testRun,
      body: null,
      method: 'GET',
      isMountedRef: isMountedRef,
    })
      .then((json: any) => {
        if (!json) {
          return
        }

        const testRun = typecheck<TestRun>(camelizeKeys(json), 'testRun')

        if (testRun) {
          setTab('results')
        }

        updateSubmission(testRun)
      })
      .finally(() => {
        controllerRef.current = undefined
      })
  }, [initialSubmission, updateSubmission, isMountedRef])

  const revertToLastIteration = useCallback(() => {
    editorRef.current?.setFiles(submissionFilesRef.current)
  }, [editorRef, submissionFilesRef])

  const toggleKeyboardShortcuts = useCallback(() => {
    editorRef.current?.openPalette()
  }, [editorRef])

  const revertToExerciseStart = useCallback(() => {
    if (!submission) {
      return
    }

    revertDispatch({ type: RevertStatus.INITIALIZED })

    abort()
    sendRequest({
      endpoint: submission.links.initialFiles,
      body: null,
      method: 'GET',
      isMountedRef: isMountedRef,
    })
      .then((json: any) => {
        if (!json) {
          return
        }

        const files = typecheck<File[]>(json, 'files')

        editorRef.current?.setFiles(files)

        revertDispatch({ type: RevertStatus.SUCCEEDED })
      })
      .catch((err) => {
        if (err instanceof Error) {
          revertDispatch({
            type: RevertStatus.FAILED,
            payload: {
              apiError: {
                type: 'unknown',
                message: 'Unable to revert file, please try again.',
              } as APIError,
            },
          })
        }

        if (err instanceof Response) {
          err.json().then((res: any) => {
            revertDispatch({
              type: RevertStatus.FAILED,
              payload: { apiError: res.error },
            })
          })
        }
      })
      .finally(() => {
        controllerRef.current = undefined
      })
  }, [abort, isMountedRef, revertDispatch, submission])

  useEffect(() => {
    switch (submissionStatus) {
      case SubmissionStatus.CREATED:
        setStatus(EditorStatus.SUBMISSION_CREATED)
        break
      case SubmissionStatus.CANCELLED:
        setStatus(EditorStatus.SUBMISSION_CANCELLED)
        break
      case SubmissionStatus.CREATING:
        setStatus(EditorStatus.CREATING_SUBMISSION)
        break
      case SubmissionStatus.CREATING_ITERATION:
        setStatus(EditorStatus.CREATING_ITERATION)
        break
    }
  }, [submissionStatus])

  useEffect(() => {
    switch (revertStatus) {
      case RevertStatus.INITIALIZED:
        setStatus(EditorStatus.REVERTING_TO_EXERCISE_START)
        break
      case RevertStatus.SUCCEEDED:
        setStatus(EditorStatus.REVERTED)
        break
      case RevertStatus.FAILED:
        setStatus(EditorStatus.REVERT_FAILED)
        break
    }
  }, [revertStatus])

  useEffect(() => {
    setApiError(submissionApiError)
  }, [submissionApiError])

  useEffect(() => {
    setApiError(revertApiError)
  }, [revertApiError])

  return (
    <TabsContext.Provider
      value={{
        current: tab,
        switchToTab: (id: string) => setTab(id as TabIndex),
      }}
    >
      <div id="page-editor">
        <div className="header">
          <Header.Back exercisePath={exercisePath} />
          <Header.Title trackTitle={trackTitle} exerciseTitle={exerciseTitle} />
          <Header.ActionHints assignment={assignment} />
          <Header.ActionKeyboardShortcuts
            ref={keyboardShortcutsRef}
            onClick={toggleKeyboardShortcuts}
          />
          <Header.ActionSettings
            theme={theme}
            keybindings={keybindings}
            wrap={wrap}
            setTheme={setTheme}
            setKeybindings={setKeybindings}
            setWrap={setWrap}
          />
          <Header.ActionMore
            onRevertToExerciseStart={revertToExerciseStart}
            onRevertToLastIteration={revertToLastIteration}
            isRevertToLastIterationDisabled={isEqual(
              submissionFilesRef.current,
              files
            )}
          />
        </div>

        <div className="main-lhs">
          <FileEditor
            editorDidMount={editorDidMount}
            files={files}
            language={language}
            theme={theme}
            keybindings={keybindings}
            wrap={wrap}
            onRunTests={runTests}
            onSubmit={submit}
          />
        </div>
        <StoredScrollPanel tab={tab}>
          <InstructionsPanel
            introduction={introduction}
            assignment={assignment}
            exampleFiles={exampleFiles}
            debuggingInstructions={debuggingInstructions}
          />
          <TestsPanel />
          <ResultsPanel
            submission={submission}
            timeout={timeout}
            onUpdate={updateSubmission}
            onSubmit={submit}
            isSubmitDisabled={isSubmitDisabled}
          />
        </StoredScrollPanel>
        <div className="footer-lhs">
          <EditorStatusSummary
            status={status}
            onCancel={cancel}
            error={apiError?.message}
          />
          <RunTestsButton onClick={runTests} />
          <SubmitButton onClick={submit} disabled={isSubmitDisabled} />
        </div>

        <div className="footer-rhs">
          <div className="tabs">
            <InstructionsTab />
            <TestsTab />
            <ResultsTab />
          </div>
        </div>
      </div>
    </TabsContext.Provider>
  )
}
