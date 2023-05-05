import React, {
  useRef,
  useCallback,
  useState,
  useEffect,
  createContext,
} from 'react'
import { useQueryCache } from 'react-query'
import { redirectTo } from '@/utils/redirect-to'
import { getCacheKey } from '@/components/student'
import type { File } from './types'
import { type TabContext, SplitPane } from './common'
import {
  type Props,
  type EditorFeatures,
  type TaskContext,
  type FileEditorHandle,
  type TestRun,
  useSubmissionCancelling,
  useDefaultSettings,
  useEditorStatus,
  useSubmissionsList,
  useFileRevert,
  useIteration,
  useEditorFiles,
  useSaveFiles,
  useEditorTestRunStatus,
  TestRunStatus,
  EditorStatus,
  useEditorFocus,
  Header,
  FileEditorCodeMirror,
  EditorStatusSummary,
  RunTestsButton,
  SubmitButton,
  InstructionsTab,
  TestsTab,
  ResultsTab,
  FeedbackTab,
  InstructionsPanel,
  TestPanel,
  TestsPanel,
  ResultsPanel,
  FeedbackPanel,
} from './editor/index'
import { TestContentWrapper } from './editor/TestContentWrapper'
import * as ChatGPT from './editor/ChatGptFeedback'

type TabIndex = 'instructions' | 'tests' | 'results' | 'chatgpt'

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
  switchToTab: () => null,
})

export const FeaturesContext = createContext<EditorFeatures>({
  theme: false,
  keybindings: false,
})

export const TasksContext = createContext<TaskContext>({
  current: null,
  switchToTask: () => null,
  showJumpToInstructionButton: false,
})

export default ({
  timeout = 60000,
  defaultSubmissions,
  insidersStatus,
  defaultFiles,
  defaultSettings,
  autosave,
  panels,
  track,
  exercise,
  links,
  iteration,
  discussion,
  mentoringRequested,
  chatgptUsage,
  features = { theme: false, keybindings: false },
}: Props): JSX.Element => {
  const editorRef = useRef<FileEditorHandle>()
  const runTestsButtonRef = useRef<HTMLButtonElement>(null)
  const submitButtonRef = useRef<HTMLButtonElement>(null)

  const [hasCancelled, setHasCancelled] = useSubmissionCancelling()
  const [tab, setTab] = useState<TabIndex>('instructions')
  const [task, setTask] = useState<number | null>(null)
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
  const cache = useQueryCache()
  const isInsider = ['active', 'active_lifetime'].includes(insidersStatus)
  const [chatGptDialogOpen, setChatGptDialogOpen] = useState(false)
  const [selectedGPTModel, setSelectedGPTModel] = useState<ChatGPT.ModelType>({
    version: '3.5',
    usage: chatgptUsage['3.5'],
  })

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
      onSuccess: async (iteration) => {
        await cache.invalidateQueries([getCacheKey(track.slug, exercise.slug)])
        redirectTo(iteration.links.solution)
      },
    })
  }, [
    cache,
    createIteration,
    dispatch,
    exercise.slug,
    isSubmitDisabled,
    submission,
    track.slug,
  ])

  const updateSubmission = useCallback(
    (testRun: TestRun) => {
      if (!submission) {
        throw 'Submission expected'
      }

      setSubmission(submission.uuid, { ...submission, testRun: testRun })
    },

    // not stringifying this will lead to an infinite loop
    // see https://github.com/exercism/website/pull/3137#discussion_r1015500657
    // eslint-disable-next-line react-hooks/exhaustive-deps
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
  }, [submission, dispatch, revertToLastIteration, setFiles, defaultFiles])

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
  }, [submission, dispatch, revertToExerciseStart, setFiles, defaultFiles])

  const handleCancelled = useCallback(() => {
    if (!submission) {
      return
    }

    removeSubmission(submission.uuid)
    setHasCancelled(true)
  }, [removeSubmission, setHasCancelled, submission])

  useEffect(() => {
    if (!submission) {
      return
    }

    setTab('results')

    if (submission.testRun?.status === TestRunStatus.CANCELLED) {
      handleCancelled()
    }
  }, [handleCancelled, submission])

  useEditorFocus({ editor: editorRef.current, isProcessing })

  const {
    mutation: pokeChatGpt,
    status: chatGptFetchingStatus,
    helpRecord,
    setSubmissionUuid,
    submissionUuid,
    mutationError,
    mutationStatus,
    exceededLimit,
  } = ChatGPT.Hook({
    submission: submission ?? null,
    defaultRecord: panels.aiHelp,
    GPTModel: selectedGPTModel.version,
  })

  const invokeChatGpt = useCallback(() => {
    const status = chatGptFetchingStatus
    setTab('chatgpt')
    if (status === 'unfetched' || submissionUuid !== submission?.uuid) {
      pokeChatGpt()
      setSubmissionUuid(submission?.uuid)
    }
  }, [
    chatGptFetchingStatus,
    pokeChatGpt,
    setSubmissionUuid,
    submission?.uuid,
    submissionUuid,
  ])

  useEffect(() => {
    if (mutationStatus === 'success') {
      setChatGptDialogOpen(false)
    }
  }, [mutationStatus])

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
                  {isInsider ? (
                    <ChatGPT.Button
                      noSubmission={!submission}
                      sameSubmission={
                        submission ? submission.uuid === submissionUuid : false
                      }
                      isProcessing={isProcessing}
                      passingTests={testRunStatus === TestRunStatus.PASS}
                      chatGptFetchingStatus={chatGptFetchingStatus}
                      onClick={() => setChatGptDialogOpen(true)}
                    />
                  ) : null}
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
              <TasksContext.Provider
                value={{
                  current: task,
                  switchToTask: (id) => {
                    setTask(id)
                    setTab('instructions')
                  },
                  showJumpToInstructionButton: true,
                }}
              >
                <div className="tabs">
                  <InstructionsTab />
                  {panels.tests ? <TestsTab /> : null}
                  <ResultsTab />
                  {iteration ? <FeedbackTab /> : null}
                  {isInsider ? <ChatGPT.Tab /> : null}
                </div>
                <InstructionsPanel {...panels.instructions} />
                {panels.tests ? (
                  <TestsPanel>
                    <TestContentWrapper
                      testTabGroupCss="border-t-1 border-borderColor6"
                      tabContext={TabsContext}
                      testFiles={panels.tests.testFiles}
                    >
                      <TestPanel {...panels.tests} />
                    </TestContentWrapper>
                  </TestsPanel>
                ) : null}
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
                {iteration ? (
                  <FeedbackPanel
                    exercise={exercise}
                    track={track}
                    iteration={iteration}
                    discussion={discussion}
                    requestedMentoring={mentoringRequested}
                    mentoringRequestLink={links.mentoringRequest}
                    automatedFeedbackInfoLink={links.automatedFeedbackInfo}
                    mentorDiscussionsLink={links.mentorDiscussions}
                  />
                ) : null}
                {isInsider && (
                  <ChatGPT.Panel
                    helpRecord={helpRecord}
                    status={chatGptFetchingStatus}
                  />
                )}
              </TasksContext.Provider>
            }
          />

          {submission && (
            <ChatGPT.Dialog
              onClose={() => setChatGptDialogOpen(false)}
              open={chatGptDialogOpen}
              submission={submission}
              value={selectedGPTModel}
              setValue={setSelectedGPTModel}
              onGo={invokeChatGpt}
              chatgptUsage={chatgptUsage}
              error={mutationError}
              exceededLimit={exceededLimit}
            />
          )}
        </div>
      </TabsContext.Provider>
    </FeaturesContext.Provider>
  )
}
