import React, {
  useRef,
  useCallback,
  useState,
  useEffect,
  createContext,
} from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { getCacheKey } from '@/components/student'
import { redirectTo } from '@/utils'
import type { File } from './types'
import { type TabContext } from './common'
import { SplitPane } from './common/SplitPane'
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
  GetHelpPanel,
  GetHelpTab,
  StuckButton,
  TestContentWrapper,
  ChatGPT,
} from './editor/index'
import { RealtimeFeedbackModal } from './modals'
import { ChatGptTab } from './editor/ChatGptFeedback/ChatGptTab'
import { ChatGptPanel } from './editor/ChatGptFeedback/ChatGptPanel'

export type TabIndex =
  | 'instructions'
  | 'tests'
  | 'results'
  | 'get-help'
  | 'chat-gpt'

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
  insider,
  defaultFiles,
  defaultSettings,
  autosave,
  panels,
  help,
  track,
  exercise,
  solution,
  links,
  iteration,
  discussion,
  request,
  mentoringStatus,
  chatgptUsage,
  trackObjectives,
  showDeepDiveVideo,
  hasAvailableMentoringSlot,
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
  const [feedbackModalOpen, setFeedbackModalOpen] = useState(false)
  const [redirectLink, setRedirectLink] = useState('')
  const [hasLatestIteration, setHasLatestIteration] = useState(false)
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
  const [isProcessing, setIsProcessing] = useState(false)
  const haveFilesChanged =
    submission === null ||
    !filesEqual(submissionFiles, files) ||
    testRunStatus === TestRunStatus.OPS_ERROR ||
    testRunStatus === TestRunStatus.TIMEOUT ||
    testRunStatus === TestRunStatus.CANCELLED
  const queryClient = useQueryClient()
  const [chatGptDialogOpen, setChatGptDialogOpen] = useState(false)
  const [selectedGPTModel, setSelectedGPTModel] = useState<ChatGPT.ModelType>({
    version: '3.5',
    usage: chatgptUsage['3.5'],
  })

  useEffect(() => {
    if (
      status === EditorStatus.CREATING_SUBMISSION ||
      status === EditorStatus.CREATING_ITERATION ||
      testRunStatus === TestRunStatus.QUEUED
    )
      setIsProcessing(true)
    else setIsProcessing(false)
  }, [status, testRunStatus])

  const runTests = useCallback(() => {
    dispatch({ status: EditorStatus.CREATING_SUBMISSION })

    createSubmission(files, {
      onSuccess: () => {
        dispatch({ status: EditorStatus.INITIALIZED })
        setSubmissionFiles(files)
        setHasLatestIteration(false)
      },
      onError: async (error) => {
        let editorError: null | Promise<{ type: string; message: string }> =
          null

        if (error instanceof Error) {
          editorError = Promise.resolve({
            type: 'unknown',
            message: 'Unable to submit file. Please try again.',
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

        if (editorError) {
          dispatch({
            status: EditorStatus.CREATE_SUBMISSION_FAILED,
            error: await editorError,
          })
        }
      },
    })
  }, [createSubmission, dispatch, files])

  const showFeedbackModal = useCallback(() => {
    setFeedbackModalOpen(true)
  }, [])
  const hideFeedbackModal = useCallback(() => {
    setFeedbackModalOpen(false)
    setIsProcessing(false)
  }, [])

  const submit = useCallback(() => {
    if (isSubmitDisabled) {
      return
    }

    if (!submission) {
      throw 'Submission expected'
    }

    if (exercise.slug !== 'hello-world') {
      showFeedbackModal()
    }

    if (!hasLatestIteration) {
      dispatch({ status: EditorStatus.CREATING_ITERATION })
      createIteration(submission, {
        onSuccess: async (iteration) => {
          await queryClient.invalidateQueries({
            queryKey: [getCacheKey(track.slug, exercise.slug)],
          })

          if (exercise.slug === 'hello-world') {
            redirectTo(iteration.links.solution)
          }
          setRedirectLink(iteration.links.solution)
          setHasLatestIteration(true)
        },
      })
    }
  }, [
    queryClient,
    createIteration,
    dispatch,
    exercise.slug,
    hasLatestIteration,
    isSubmitDisabled,
    showFeedbackModal,
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
        let editorError: null | Promise<{ type: string; message: string }> =
          null

        if (err instanceof Error) {
          editorError = Promise.resolve({
            type: 'unknown',
            message: 'Unable to revert file, please try again.',
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

        if (editorError) {
          dispatch({
            status: EditorStatus.REVERT_FAILED,
            error: await editorError,
          })
        }
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
        let editorError: null | Promise<{ type: string; message: string }> =
          null

        if (err instanceof Error) {
          editorError = Promise.resolve({
            type: 'unknown',
            message: 'Unable to revert file, please try again.',
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

        if (editorError) {
          dispatch({
            status: EditorStatus.REVERT_FAILED,
            error: await editorError,
          })
        }
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
    chatGptUsage,
  } = ChatGPT.Hook({
    submission: submission ?? null,
    defaultRecord: panels.aiHelp,
    GPTModel: selectedGPTModel.version,
    chatgptUsage,
  })

  const invokeChatGpt = useCallback(() => {
    const status = chatGptFetchingStatus
    setTab('get-help')
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
                  <StuckButton insider={insider} tab={tab} setTab={setTab} />
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
                  <ChatGptTab />
                  <GetHelpTab />
                </div>
                <InstructionsPanel
                  {...panels.instructions}
                  tutorial={exercise.slug === 'hello-world'}
                />
                {panels.tests ? (
                  <TestsPanel context={TabsContext}>
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
                    requestedMentoring={mentoringStatus === 'requested'}
                    mentoringRequestLink={links.mentoringRequest}
                    automatedFeedbackInfoLink={links.automatedFeedbackInfo}
                    mentorDiscussionsLink={links.mentorDiscussions}
                  />
                ) : null}
                <ChatGptPanel>
                  {insider ? (
                    <ChatGPT.Wrapper
                      helpRecord={helpRecord}
                      status={chatGptFetchingStatus}
                    >
                      <ChatGPT.Button
                        insider={insider}
                        noSubmission={!submission}
                        sameSubmission={
                          submission
                            ? submission.uuid === submissionUuid
                            : false
                        }
                        isProcessing={isProcessing}
                        passingTests={testRunStatus === TestRunStatus.PASS}
                        chatGptFetchingStatus={chatGptFetchingStatus}
                        onClick={() => setChatGptDialogOpen(true)}
                      />
                    </ChatGPT.Wrapper>
                  ) : (
                    <ChatGPT.UpsellContent />
                  )}
                </ChatGptPanel>
                <GetHelpPanel
                  assignment={panels.instructions.assignment}
                  helpHtml={help.html}
                  links={links}
                  track={track}
                />
              </TasksContext.Provider>
            }
          />
          <RealtimeFeedbackModal
            open={feedbackModalOpen}
            onClose={hideFeedbackModal}
            discussion={discussion}
            mentoringStatus={mentoringStatus}
            showDeepDiveVideo={showDeepDiveVideo}
            onSubmit={submit}
            solution={solution}
            track={track}
            request={request}
            submission={submission}
            exercise={exercise}
            trackObjectives={trackObjectives}
            hasAvailableMentoringSlot={hasAvailableMentoringSlot}
            links={{ ...links, redirectToExerciseLink: redirectLink }}
          />

          {submission && insider && (
            <ChatGPT.Dialog
              onClose={() => setChatGptDialogOpen(false)}
              open={chatGptDialogOpen}
              submission={submission}
              value={selectedGPTModel}
              setValue={setSelectedGPTModel}
              onGo={invokeChatGpt}
              chatgptUsage={chatGptUsage}
              error={mutationError}
              exceededLimit={exceededLimit}
            />
          )}
        </div>
      </TabsContext.Provider>
    </FeaturesContext.Provider>
  )
}
