import React, {
  useRef,
  useCallback,
  useState,
  useEffect,
  createContext,
} from 'react'
import { TestRun, TestRunStatus } from './editor/types'
import { File } from './types'
import { Props, EditorFeatures } from './editor/Props'
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
import { redirectTo } from '../utils/redirect-to'
import { TabContext } from './common/Tab'
import { SplitPane } from './common'

import { useSaveFiles } from './editor/useSaveFiles'
import { useEditorFiles } from './editor/useEditorFiles'
import { useEditorFocus } from './editor/useEditorFocus'
import { useSubmissionsList } from './editor/useSubmissionsList'
import { useFileRevert } from './editor/useFileRevert'
import { useIteration } from './editor/useIteration'
import { useDefaultSettings } from './editor/useDefaultSettings'
import { useEditorStatus, EditorStatus } from './editor/useEditorStatus'
import { useEditorTestRunStatus } from './editor/useEditorTestRunStatus'
import { useSubmissionCancelling } from './editor/useSubmissionCancelling'

type TabIndex = 'instructions' | 'tests' | 'results'

const filesEqual = (files: File[], other: File[]) => {
  if (files.length !== other.length) {
    return false
  }

  return files.every((f, i) => {
    return f.content === other[i].content
  })
}

export const TabsContext = createContext<TabContext>({
  current: 'instructions',
  switchToTab: () => {},
})

export const FeaturesContext = createContext<EditorFeatures>({
  theme: false,
  keybindings: false,
})

export default ({
  timeout = 60000,
  defaultSubmissions,
  defaultFiles,
  defaultSettings,
  autosave,
  panels,
  track,
  exercise,
  links,
  features = { theme: false, keybindings: false },
}: Props): JSX.Element => {
  const editorRef = useRef<FileEditorHandle>()
  const runTestsButtonRef = useRef<HTMLButtonElement>(null)
  const submitButtonRef = useRef<HTMLButtonElement>(null)

  const [hasCancelled, setHasCancelled] = useSubmissionCancelling()
  const [tab, setTab] = useState<TabIndex>('instructions')
  const [settings, setSettings] = useDefaultSettings(defaultSettings)
  const [{ status, error }, dispatch] = useEditorStatus()
  const [submissionFiles, setSubmissionFiles] = useState<File[]>(defaultFiles)
  const {
    create: createSubmission,
    current: submission,
    set: setSubmission,
    remove: removeSubmission,
  } = useSubmissionsList(defaultSubmissions, { create: links.runTests })
  const { revertToExerciseStart, revertToLastIteration } = useFileRevert()
  const { create: createIteration } = useIteration()
  const { get: getFiles, set: setFiles } = useEditorFiles({
    defaultFiles,
    editorRef,
  })
  const [files] = useSaveFiles({ getFiles, ...autosave })
  const testRunStatus = useEditorTestRunStatus(submission)
  const isSubmitDisabled =
    testRunStatus !== TestRunStatus.PASS || !filesEqual(submissionFiles, files)
  const isProcessing =
    status === EditorStatus.CREATING_SUBMISSION ||
    status === EditorStatus.CREATING_ITERATION ||
    testRunStatus === TestRunStatus.QUEUED
  const haveFilesChanged =
    submission === null ||
    !filesEqual(submissionFiles, files) ||
    testRunStatus === TestRunStatus.OPS_ERROR ||
    testRunStatus === TestRunStatus.TIMEOUT ||
    testRunStatus === TestRunStatus.CANCELLED

  const runTests = useCallback(() => {
    dispatch({ status: EditorStatus.CREATING_SUBMISSION })

    createSubmission(files, {
      onSuccess: () => {
        dispatch({ status: EditorStatus.INITIALIZED })
        setSubmissionFiles(files)
      },
      onError: async (error) => {
        let editorError = null

        if (error instanceof Error) {
          editorError = Promise.resolve(() => {
            return {
              type: 'unknown',
              message: 'Unable to submit file. Please try again.',
            }
          })
        } else if (error instanceof Response) {
          editorError = error
            .json()
            .then((json) => json.error)
            .catch(() => {
              return {
                type: 'unknown',
                message: 'Unable to submit file. Please try again.',
              }
            })
        }

        dispatch({
          status: EditorStatus.CREATE_SUBMISSION_FAILED,
          error: await editorError,
        })
      },
    })
  }, [createSubmission, dispatch, files])

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
      return setFiles(defaultFiles)
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
          editorError = Promise.resolve(() => {
            return {
              type: 'unknown',
              message: 'Unable to revert file, please try again.',
            }
          })
        } else if (err instanceof Response) {
          editorError = err
            .json()
            .then((json) => json.error)
            .catch(() => {
              return {
                type: 'unknown',
                message: 'Unable to revert file, please try again.',
              }
            })
        }

        dispatch({
          status: EditorStatus.REVERT_FAILED,
          error: await editorError,
        })
      },
    })
  }, [revertToLastIteration, dispatch, setFiles, JSON.stringify(submission)])

  const handleRevertToExerciseStart = useCallback(() => {
    if (!submission) {
      return setFiles(defaultFiles)
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
          editorError = Promise.resolve(() => {
            return {
              type: 'unknown',
              message: 'Unable to revert file, please try again.',
            }
          })
        } else if (err instanceof Response) {
          editorError = err
            .json()
            .then((json) => json.error)
            .catch(() => {
              return {
                type: 'unknown',
                message: 'Unable to revert file, please try again.',
              }
            })
        }

        dispatch({
          status: EditorStatus.REVERT_FAILED,
          error: await editorError,
        })
      },
    })
  }, [revertToExerciseStart, setFiles, dispatch, JSON.stringify(submission)])

  const handleCancelled = useCallback(() => {
    if (!submission) {
      return
    }

    removeSubmission(submission.uuid)
    setHasCancelled(true)
  }, [JSON.stringify(submission)])

  useEffect(() => {
    if (!submission) {
      return
    }

    setTab('results')

    if (submission.testRun?.status === TestRunStatus.CANCELLED) {
      handleCancelled()
    }
  }, [JSON.stringify(submission)])

  useEditorFocus({ editor: editorRef.current, isProcessing })

  return (
    <FeaturesContext.Provider value={features}>
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
                trackSlug={track.slug}
                exerciseSlug={exercise.slug}
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
                  language={track.slug}
                  settings={settings}
                  onRunTests={() => {
                    runTestsButtonRef.current?.focus()
                    runTestsButtonRef.current?.click()
                  }}
                  onSubmit={() => {
                    submitButtonRef.current?.focus()
                    submitButtonRef.current?.click()
                  }}
                  readonly={isProcessing}
                />

                <footer className="lhs-footer">
                  <EditorStatusSummary status={status} error={error?.message} />
                  <RunTestsButton
                    onClick={runTests}
                    haveFilesChanged={haveFilesChanged}
                    isProcessing={isProcessing}
                    ref={runTestsButtonRef}
                  />
                  <SubmitButton
                    onClick={submit}
                    disabled={isSubmitDisabled}
                    ref={submitButtonRef}
                  />
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
                  hasCancelled={hasCancelled}
                  {...panels.results}
                />
              </>
            }
          />
        </div>
      </TabsContext.Provider>
    </FeaturesContext.Provider>
  )
}
