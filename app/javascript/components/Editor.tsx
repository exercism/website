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
  TabBehavior,
} from './editor/types'
import { File } from './types'
import { Iteration } from './types'
import { Header } from './editor/Header'
import { FileEditorHandle } from './editor/FileEditorAce'
import { FileEditorCodeMirror } from './editor/FileEditorCodeMirror'
import { InstructionsPanel } from './editor/InstructionsPanel'
import { TestsPanel } from './editor/TestsPanel'
import { ResultsPanel } from './editor/ResultsPanel'
import { InstructionsTab } from './editor/InstructionsTab'
import { TestsTab } from './editor/TestsTab'
import { ResultsTab } from './editor/ResultsTab'
import { EditorStatusSummary } from './editor/EditorStatusSummary'
import { RunTestsButton } from './editor/RunTestsButton'
import { SubmitButton } from './editor/SubmitButton'
import { camelizeKeys } from 'humps'
import { useSaveFiles } from './editor/useSaveFiles'
import {
  useSubmission,
  ActionType as SubmissionActionType,
  SubmissionStatus,
} from './editor/useSubmission'
import { useFileRevert, RevertStatus } from './editor/useFileRevert'
import { isEqual } from 'lodash'
import { sendRequest, APIError } from '../utils/send-request'
import { TabContext } from './common/Tab'
import { SplitPane } from './common'
import { redirectTo } from '../utils/redirect-to'
import { useMutation } from 'react-query'

type TabIndex = 'instructions' | 'tests' | 'results'

export type EditorConfig = {
  tabSize: number
  useSoftTabs: boolean
}

export enum EditorStatus {
  INITIALIZED = 'initialized',
  CREATING_SUBMISSION = 'creatingSubmission',
  SUBMISSION_CREATED = 'submissionCreated',
  CREATING_ITERATION = 'creatingIteration',
  SUBMISSION_CANCELLED = 'submissionCancelled',
  REVERTING = 'reverting',
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
  highlightJSLanguage,
  averageTestDuration,
  exercisePath,
  trackTitle,
  trackSlug,
  exerciseTitle,
  introduction,
  tests,
  assignment,
  exampleFiles,
  storageKey,
  debuggingInstructions,
  config,
  saveInterval = 500,
}: {
  endpoint: string
  timeout?: number
  initialSubmission?: Submission
  files: File[]
  highlightJSLanguage: string
  averageTestDuration: number
  exercisePath: string
  trackTitle: string
  trackSlug: string
  exerciseTitle: string
  introduction: string
  tests?: string
  assignment: Assignment
  exampleFiles: File[]
  storageKey: string
  debuggingInstructions?: string
  config: EditorConfig
  saveInterval?: number
}) {
  const [tab, setTab] = useState<TabIndex>('instructions')
  const [theme, setTheme] = useState<Themes>(Themes.LIGHT)
  const [
    { status: revertStatus, apiError: revertApiError },
    revertDispatch,
  ] = useFileRevert()
  const [apiError, setApiError] = useState<APIError | null>(null)
  const editorRef = useRef<FileEditorHandle>()
  const keyboardShortcutsRef = useRef<HTMLButtonElement>(null)
  const [submissionFiles, setSubmissionFiles] = useState<File[]>(initialFiles)
  const [files] = useSaveFiles(storageKey, initialFiles, saveInterval, () => {
    return editorRef.current?.getFiles() || initialFiles
  })
  const [keybindings, setKeybindings] = useState<Keybindings>(
    Keybindings.DEFAULT
  )
  const [wrap, setWrap] = useState<WrapSetting>('on')
  const [tabBehavior, setTabBehavior] = useState<TabBehavior>('captured')
  const [
    { submission, status: submissionStatus, apiError: submissionApiError },
    submissionDispatch,
  ] = useSubmission(initialSubmission)
  const [status, setStatus] = useState(EditorStatus.INITIALIZED)
  const [runTestsMutation] = useMutation<Submission, unknown, File[]>(
    (files) => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'POST',
        body: JSON.stringify({ files: files }),
      })

      return fetch.then((response) =>
        typecheck<Submission>(response, 'submission')
      )
    },
    {
      onSuccess: (submission) => {
        submissionDispatch({
          type: SubmissionActionType.SUBMISSION_CREATED,
          payload: { submission: submission },
        })
        setTab('results')
        setSubmissionFiles(files)
      },
      onError: (err) => {
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
      },
    }
  )

  const [submitMutation] = useMutation<Iteration>(
    () => {
      if (!submission) {
        throw 'Expected submission'
      }

      const { fetch } = sendRequest({
        endpoint: submission.links.submit,
        method: 'POST',
        body: null,
      })

      return fetch.then((json) => typecheck<Iteration>(json, 'iteration'))
    },
    {
      onSuccess: (iteration) => {
        redirectTo(iteration.links.solution)
      },
    }
  )

  const runTests = useCallback(() => {
    const files = editorRef.current?.getFiles()

    if (!files) {
      return
    }

    submissionDispatch({ type: SubmissionActionType.CREATING_SUBMISSION })
    runTestsMutation(files)
  }, [submissionDispatch, runTestsMutation])

  const submit = useCallback(() => {
    if (!submission) {
      return
    }

    if (submission.testRun?.status !== TestRunStatus.PASS) {
      return
    }

    submissionDispatch({ type: SubmissionActionType.CREATING_ITERATION })
    submitMutation()
  }, [submission, submissionDispatch, submitMutation])

  const cancel = useCallback(() => {
    submissionDispatch({ type: SubmissionActionType.SUBMISSION_CANCELLED })
  }, [submissionDispatch])

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
    !isEqual(submissionFiles, files)

  useEffect(() => {
    if (!initialSubmission) {
      return
    }

    const { fetch } = sendRequest({
      endpoint: initialSubmission.links.testRun,
      body: null,
      method: 'GET',
    })

    fetch.then((json) => {
      if (!json) {
        return
      }

      const testRun = typecheck<TestRun>(camelizeKeys(json), 'testRun')

      if (testRun) {
        setTab('results')
      }

      updateSubmission(testRun)
    })
  }, [initialSubmission, updateSubmission])

  const [revertToLastIterationMutation] = useMutation<File[]>(
    () => {
      if (!submission) {
        throw 'Submission expected'
      }

      const { fetch } = sendRequest({
        endpoint: submission.links.lastIterationFiles,
        body: null,
        method: 'GET',
      })

      return fetch.then((json) => typecheck<File[]>(json, 'files'))
    },
    {
      onSuccess: (files) => {
        editorRef.current?.setFiles(files)
        revertDispatch({ type: RevertStatus.SUCCEEDED })
      },
      onError: (err) => {
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
      },
    }
  )

  const revertToLastIteration = useCallback(() => {
    if (!submission) {
      return
    }

    revertDispatch({ type: RevertStatus.INITIALIZED })
    revertToLastIterationMutation()
  }, [revertDispatch, revertToLastIterationMutation, submission])

  const toggleKeyboardShortcuts = useCallback(() => {
    editorRef.current?.openPalette()
  }, [editorRef])

  const [revertToExerciseStartMutation] = useMutation<File[]>(
    () => {
      if (!submission) {
        throw 'Submission expected'
      }

      const { fetch } = sendRequest({
        endpoint: submission.links.initialFiles,
        body: null,
        method: 'GET',
      })

      return fetch.then((json) => typecheck<File[]>(json, 'files'))
    },
    {
      onSuccess: (files) => {
        editorRef.current?.setFiles(files)
        revertDispatch({ type: RevertStatus.SUCCEEDED })
      },
      onError: (err) => {
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
      },
    }
  )

  const revertToExerciseStart = useCallback(() => {
    if (!submission) {
      return
    }

    revertDispatch({ type: RevertStatus.INITIALIZED })
    revertToExerciseStartMutation()
  }, [revertDispatch, revertToExerciseStartMutation, submission])

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
        setStatus(EditorStatus.REVERTING)
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
          <div className="options">
            <Header.ActionHints assignment={assignment} />
            <Header.ActionKeyboardShortcuts
              ref={keyboardShortcutsRef}
              onClick={toggleKeyboardShortcuts}
            />
            <Header.ActionSettings
              theme={theme}
              keybindings={keybindings}
              wrap={wrap}
              tabBehavior={tabBehavior}
              setTheme={setTheme}
              setKeybindings={setKeybindings}
              setWrap={setWrap}
              setTabBehavior={setTabBehavior}
            />
            <Header.ActionMore
              onRevertToExerciseStart={revertToExerciseStart}
              onRevertToLastIteration={revertToLastIteration}
            />
          </div>
        </div>

        <SplitPane
          id="editor"
          left={
            <>
              <FileEditorCodeMirror
                editorDidMount={editorDidMount}
                files={files}
                language={trackSlug}
                theme={theme}
                keybindings={keybindings}
                wrap={wrap}
                tabBehavior={tabBehavior}
                onRunTests={runTests}
                onSubmit={submit}
                config={config}
              />

              <footer className="lhs-footer">
                <EditorStatusSummary
                  status={status}
                  error={apiError?.message}
                />
                <RunTestsButton
                  onClick={runTests}
                  haveFilesChanged={
                    submission === null ||
                    !isEqual(submissionFiles, files) ||
                    submission?.testRun?.status === TestRunStatus.OPS_ERROR ||
                    submission?.testRun?.status === TestRunStatus.TIMEOUT ||
                    submission?.testRun?.status === TestRunStatus.CANCELLED
                  }
                  isProcessing={
                    submissionStatus === SubmissionStatus.CREATING ||
                    submission?.testRun?.status === TestRunStatus.QUEUED ||
                    submission?.testRun?.status === TestRunStatus.CANCELLING
                  }
                />
                <SubmitButton onClick={submit} disabled={isSubmitDisabled} />
              </footer>
            </>
          }
          right={
            <>
              <div className="tabs">
                <InstructionsTab />
                {tests ? <TestsTab /> : null}
                <ResultsTab />
              </div>
              <InstructionsPanel
                introduction={introduction}
                assignment={assignment}
                exampleFiles={exampleFiles}
                debuggingInstructions={debuggingInstructions}
              />
              {tests ? (
                <TestsPanel tests={tests} language={highlightJSLanguage} />
              ) : null}
              <ResultsPanel
                submission={submission}
                timeout={timeout}
                onUpdate={updateSubmission}
                onRunTests={runTests}
                onSubmit={submit}
                isSubmitDisabled={isSubmitDisabled}
                averageTestDuration={averageTestDuration}
              />
            </>
          }
        />
      </div>
    </TabsContext.Provider>
  )
}
