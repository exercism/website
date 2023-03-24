import React, { useCallback, useEffect, useState } from 'react'
import { useQueryCache } from 'react-query'
import { usePaginatedRequestQuery, useTimeout } from '@/hooks'
import { SolutionChannel } from '@/channels/solutionChannel'
import { AnalyzerFeedback } from '@/components/student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '@/components/student/iterations-list/RepresenterFeedback'
import { Modal } from './Modal'
import { Solution } from '../editor/Props'
import { Iteration, IterationStatus, Track } from '../types'
import { redirectTo } from '@/utils/redirect-to'
import { IterationsListRequest } from '../student/IterationsList'
import { Submission } from '../editor/types'
import { GraphicalIcon } from '../common'
import { AnalysisStatusSummary } from '../track/iteration-summary/AnalysisStatusSummary'

type RealtimeFeedbackModalProps = {
  open: boolean
  onClose: () => void
  onSubmit: () => void
  solution: Solution
  track: Pick<Track, 'iconUrl' | 'title'>
  automatedFeedbackInfoLink: string
  request: IterationsListRequest
  redirectLink: string
  submission: Submission | null
}

type ResolvedIteration = Iteration & { submissionUuid?: string }

const REFETCH_INTERVAL = 2000
const BROADCAST_TIMEOUT_IN_SECONDS = 10
const PENDING_STATUS = [
  IterationStatus.DELETED,
  IterationStatus.UNTESTED,
  IterationStatus.TESTING,
  IterationStatus.ANALYZING,
]

export const RealtimeFeedbackModal = ({
  open,
  onClose,
  solution,
  track,
  request,
  automatedFeedbackInfoLink,
  redirectLink,
  submission,
}: RealtimeFeedbackModalProps): JSX.Element => {
  const [checkStatus, setCheckStatus] = useState('loading')
  const queryCache = useQueryCache()
  const CACHE_KEY = `editor-${solution.uuid}-feedback`

  const [queryEnabled, setQueryEnabled] = useState(false)
  const [latestIteration, setLatestIteration] = useState<ResolvedIteration>()
  const [itIsTakingTooLong, setItIsTakingTooLong] = useState(false)
  const { resolvedData } = usePaginatedRequestQuery<{
    iterations: ResolvedIteration[]
  }>(CACHE_KEY, {
    ...request,
    options: {
      ...request.options,
      refetchInterval: queryEnabled ? REFETCH_INTERVAL : false,
    },
  })

  const [startTimer, restartTimer] = useTimeout(
    BROADCAST_TIMEOUT_IN_SECONDS,
    () => setItIsTakingTooLong(true)
  )

  useEffect(() => {
    if (open) startTimer(true)
    else startTimer(false)

    restartTimer(true)
    setItIsTakingTooLong(false)
  }, [open, restartTimer, startTimer])

  useEffect(() => {
    const lastIteration =
      resolvedData?.iterations[resolvedData.iterations.length - 1]
    if (
      lastIteration &&
      submission?.uuid === lastIteration?.submissionUuid &&
      !PENDING_STATUS.includes(lastIteration.status)
    ) {
      setLatestIteration(lastIteration)
      setCheckStatus(lastIteration.status)
    } else {
      setCheckStatus('loading')
      setLatestIteration(undefined)
    }
  }, [latestIteration, resolvedData, submission])

  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { uuid: solution.uuid },
      (response) => {
        queryCache.setQueryData(CACHE_KEY, { iterations: response.iterations })
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [CACHE_KEY, queryCache, solution])

  useEffect(() => {
    if (!latestIteration) {
      return
    }

    switch (latestIteration.status) {
      case IterationStatus.DELETED:
      case IterationStatus.UNTESTED:
      case IterationStatus.TESTING:
      case IterationStatus.ANALYZING:
        setQueryEnabled(true)
        break
      default:
        setQueryEnabled(false)
        break
    }
  }, [latestIteration])

  const continueAnyway = useCallback(() => {
    redirectTo(redirectLink)
  }, [redirectLink])

  function FeedbackContent() {
    switch (checkStatus) {
      case 'loading':
        return (
          <div className="flex flex-col gap-16">
            <div className="flex gap-8 text-h4 text-textColor1">
              <GraphicalIcon
                icon="spinner"
                className="animate-spin filter-textColor1"
                height={24}
                width={24}
              />
              Checking for automated feedback...{' '}
            </div>
            {itIsTakingTooLong && <TakingTooLong onClick={continueAnyway} />}
          </div>
        )
      case 'no_automated_feedback':
        return (
          <h3 className="text-h4">
            There is no automated feedback for your solution
          </h3>
        )
      default:
        return (
          <div className="flex-col items-left">
            <div className="text-h4 mb-16 flex c-iteration-summary">
              We&apos;ve found some automated feedback
              {latestIteration ? (
                <AnalysisStatusSummary
                  numEssentialAutomatedComments={
                    latestIteration.numEssentialAutomatedComments
                  }
                  numActionableAutomatedComments={
                    latestIteration.numActionableAutomatedComments
                  }
                  numNonActionableAutomatedComments={
                    latestIteration.numNonActionableAutomatedComments
                  }
                />
              ) : null}
            </div>
            {latestIteration?.representerFeedback ? (
              <RepresenterFeedback {...latestIteration.representerFeedback} />
            ) : null}
            {latestIteration?.analyzerFeedback ? (
              <AnalyzerFeedback
                {...latestIteration.analyzerFeedback}
                track={track}
                automatedFeedbackInfoLink={automatedFeedbackInfoLink}
              />
            ) : null}
            <div className="flex gap-16 mt-16">
              <ContinueAnyway onClick={continueAnyway} />
              <GoBackToExercise onClick={onClose} />
            </div>
          </div>
        )
    }
  }

  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick
      ReactModalClassName="max-w-[40%]"
    >
      <FeedbackContent />
    </Modal>
  )
}

function GoBackToExercise({ ...props }): JSX.Element {
  return (
    <button
      {...props}
      className="mr-16 px-[18px] py-[12px] border border-1 border-primaryBtnBorder text-primaryBtnBorder text-16 rounded-8 font-semibold shadow-xsZ1v2"
    >
      Go back to editor
    </button>
  )
}

function ContinueAnyway({ onClick }: { onClick: () => void }): JSX.Element {
  return (
    <button onClick={onClick} className="btn-primary btn-s">
      Continue anyway
    </button>
  )
}

function TakingTooLong({ onClick }: { onClick: () => void }): JSX.Element {
  return (
    <div>
      <p className="mb-16 text-p-base">
        Sorry, this is taking a little long.
        <br />
        We&apos;ll continue generating feedback in the background.
      </p>
      <button onClick={onClick} className="btn-primary btn-s">
        Continue
      </button>
    </div>
  )
}
