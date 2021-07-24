import React, {
  useRef,
  useCallback,
  useState,
  useEffect,
  createContext,
} from 'react'
import {
  Submission,
  TestRun,
  TestRunStatus,
  Assignment,
  EditorSettings,
} from './editor/types'
import { File } from './types'
import { Header } from './editor/Header'
import {
  FileEditorCodeMirror,
  FileEditorHandle,
} from './editor/FileEditorCodeMirror'
import { InstructionsPanel } from './editor/InstructionsPanel'
import { TestsPanel } from './editor/TestsPanel'
import { ResultsPanel } from './editor/ResultsPanel'
import { InstructionsTab } from './editor/InstructionsTab'
import { TestsTab } from './editor/TestsTab'
import { ResultsTab } from './editor/ResultsTab'
import { EditorStatusSummary } from './editor/EditorStatusSummary'
import { RunTestsButton } from './editor/RunTestsButton'
import { SubmitButton } from './editor/SubmitButton'
import { isEqual } from 'lodash'
import { redirectTo } from '../utils/redirect-to'
import { TabContext } from './common/Tab'
import { SplitPane } from './common'

import { useSaveFiles } from './editor/useSaveFiles'
import { useEditorFiles } from './editor/useEditorFiles'
import { useSubmissionsList } from './editor/useSubmissionsList'
import { useFileRevert } from './editor/useFileRevert'
import { useIteration } from './editor/useIteration'
import { useDefaultSettings } from './editor/useDefaultSettings'
import { useEditorStatus, EditorStatus } from './editor/useEditorStatus'
import { useEditorTestRunStatus } from './editor/useEditorTestRunStatus'

type TabIndex = 'instructions' | 'tests' | 'results'

type Links = {
  runTests: string
  back: string
}

type EditorPanels = {
  instructions: {
    introduction: string
    debuggingInstructions?: string
    assignment: Assignment
    exampleFiles: File[]
  }
  tests?: {
    tests: string
    language: string
  }
  results: {
    averageTestDuration: number
  }
}

type Track = {
  title: string
  slug: string
}

type Exercise = {
  title: string
}

type AutosaveConfig = {
  key: string
  saveInterval: number
}

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export type Props = {
  timeout?: number
  defaultSubmissions: Submission[]
  defaultFiles: File[]
  defaultSettings: Partial<EditorSettings>
  autosave: AutosaveConfig
  panels: EditorPanels
  track: Track
  exercise: Exercise
  links: Links
}

export function Editor({
  timeout = 60000,
  defaultSubmissions,
  defaultFiles,
  defaultSettings,
  autosave,
  panels,
  track,
  exercise,
  links,
}: Props): JSX.Element {
  const editorRef = useRef<FileEditorHandle>()

  const [tab, setTab] = useState<TabIndex>('instructions')
  const [settings, setSettings] = useDefaultSettings(defaultSettings)
  const [{ status, error }, dispatch] = useEditorStatus()
  const [submissionFiles, setSubmissionFiles] = useState<File[]>(defaultFiles)
  const {
    create: createSubmission,
    current: submission,
    set: setSubmission,
  } = useSubmissionsList(defaultSubmissions, { create: links.runTests })
  const { revertToExerciseStart, revertToLastIteration } = useFileRevert()
  const { create: createIteration } = useIteration()
  const { get: getFiles, set: setFiles } = useEditorFiles({
    defaultFiles,
    editorRef,
  })
  const [savedFiles] = useSaveFiles({ getFiles, ...autosave })
  const testRunStatus = useEditorTestRunStatus(submission)
  const isSubmitDisabled =
    testRunStatus !== TestRunStatus.PASS ||
    !isEqual(submissionFiles, getFiles())
  const isProcessing =
    status === EditorStatus.CREATING_SUBMISSION ||
    status === EditorStatus.CREATING_ITERATION ||
    testRunStatus === TestRunStatus.QUEUED
  const haveFilesChanged =
    submission === null ||
    !isEqual(submissionFiles, getFiles()) ||
    testRunStatus === TestRunStatus.OPS_ERROR ||
    testRunStatus === TestRunStatus.TIMEOUT ||
    testRunStatus === TestRunStatus.CANCELLED

  const runTests = useCallback(() => {
    dispatch({ status: EditorStatus.CREATING_SUBMISSION })

    createSubmission(getFiles(), {
      onSuccess: () => {
        dispatch({ status: EditorStatus.INITIALIZED })
        setSubmissionFiles(getFiles())
      },
      onError: (error) => {
        let editorError = null

        if (error instanceof Response) {
          error.json().then((res) => {
            editorError = res.error
          })
        }

        dispatch({
          status: EditorStatus.CREATE_SUBMISSION_FAILED,
          error: editorError,
        })
      },
    })
  }, [createSubmission, dispatch, getFiles])

  const submit = useCallback(() => {
    if (isSubmitDisabled) {
      return
    }

    if (!submission) {
      throw 'Submission expected'
    }

    dispatch({ status: EditorStatus.CREATING_ITERATION })

    createIteration(submission, {
      onSuccess: (iteration) => {
        redirectTo(iteration.links.solution)
      },
    })
  }, [createIteration, dispatch, isSubmitDisabled, JSON.stringify(submission)])

  const updateSubmission = useCallback(
    (testRun: TestRun) => {
      if (!submission) {
        throw 'Submission expected'
      }

      setSubmission(submission.uuid, { ...submission, testRun: testRun })
    },
    [setSubmission, JSON.stringify(submission)]
  )
  const editorDidMount = useCallback(
    (editor) => {
      editorRef.current = editor
    },
    [editorRef]
  )

  const handleRevertToLastIteration = useCallback(() => {
    if (!submission) {
      return
    }

    dispatch({ status: EditorStatus.REVERTING })

    revertToLastIteration(submission, {
      onSuccess: (files) => {
        dispatch({ status: EditorStatus.INITIALIZED })
        setFiles(files)
      },
      onError: async (err) => {
        let editorError = null

        if (err instanceof Error) {
          editorError = {
            type: 'unknown',
            message: 'Unable to revert file, please try again.',
          }
        } else if (err instanceof Response) {
          editorError = (await err.json()).error
        }

        dispatch({ status: EditorStatus.REVERT_FAILED, error: editorError })
      },
    })
  }, [revertToLastIteration, dispatch, setFiles, JSON.stringify(submission)])

  const handleRevertToExerciseStart = useCallback(() => {
    if (!submission) {
      return
    }

    dispatch({ status: EditorStatus.REVERTING })

    revertToExerciseStart(submission, {
      onSuccess: (files) => {
        dispatch({ status: EditorStatus.INITIALIZED })
        setFiles(files)
      },
      onError: async (err) => {
        let editorError = null

        if (err instanceof Error) {
          editorError = {
            type: 'unknown',
            message: 'Unable to revert file, please try again.',
          }
        } else if (err instanceof Response) {
          editorError = (await err.json()).error
        }

        dispatch({ status: EditorStatus.REVERT_FAILED, error: editorError })
      },
    })
  }, [revertToExerciseStart, setFiles, dispatch, JSON.stringify(submission)])

  useEffect(() => {
    if (!submission) {
      return
    }

    setTab('results')
  }, [JSON.stringify(submission)])

  useEffect(() => {
    setFiles(savedFiles)
  }, [JSON.stringify(savedFiles), setFiles])

  return (
    <TabsContext.Provider
      value={{
        current: tab,
        switchToTab: (id: string) => setTab(id as TabIndex),
      }}
    >
      <div id="page-editor">
        <div className="header">
          <Header.Back exercisePath={links.back} />
          <Header.Title
            trackTitle={track.title}
            exerciseTitle={exercise.title}
          />
          <div className="options">
            <Header.ActionHints assignment={panels.instructions.assignment} />
            <Header.ActionSettings
              settings={settings}
              setSettings={setSettings}
            />
            <Header.ActionMore
              onRevertToExerciseStart={handleRevertToExerciseStart}
              onRevertToLastIteration={handleRevertToLastIteration}
            />
          </div>
        </div>

        <SplitPane
          id="editor"
          left={
            <>
              <FileEditorCodeMirror
                editorDidMount={editorDidMount}
                files={getFiles()}
                language={track.slug}
                settings={settings}
                onRunTests={runTests}
                onSubmit={submit}
              />

              <footer className="lhs-footer">
                <EditorStatusSummary status={status} error={error?.message} />
                <RunTestsButton
                  onClick={runTests}
                  haveFilesChanged={haveFilesChanged}
                  isProcessing={isProcessing}
                />
                <SubmitButton onClick={submit} disabled={isSubmitDisabled} />
              </footer>
            </>
          }
          right={
            <>
              <div className="tabs">
                <InstructionsTab />
                {panels.tests ? <TestsTab /> : null}
                <ResultsTab />
              </div>
              <InstructionsPanel {...panels.instructions} />
              {panels.tests ? <TestsPanel {...panels.tests} /> : null}
              <ResultsPanel
                submission={submission}
                timeout={timeout}
                onUpdate={updateSubmission}
                onRunTests={runTests}
                onSubmit={submit}
                isSubmitDisabled={isSubmitDisabled}
                {...panels.results}
              />
            </>
          }
        />
      </div>
    </TabsContext.Provider>
  )
}
