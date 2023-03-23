import React, { useCallback, useEffect, useState } from 'react'
import { useQueryCache } from 'react-query'
import { usePaginatedRequestQuery } from '@/hooks'
import { SolutionChannel } from '@/channels/solutionChannel'
import { AnalyzerFeedback } from '@/components/student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '@/components/student/iterations-list/RepresenterFeedback'
import { Modal } from './Modal'
import { Solution } from '../editor/Props'
import { Iteration, IterationStatus, Track } from '../types'
import { redirectTo } from '@/utils/redirect-to'
import { IterationsListRequest } from '../student/IterationsList'
import { Submission } from '../editor/types'

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

  const [queryEnabled, setQueryEnabled] = useState(true)
  const [latestIteration, setLatestIteration] = useState<ResolvedIteration>()
  const { resolvedData } = usePaginatedRequestQuery<{
    iterations: ResolvedIteration[]
  }>(CACHE_KEY, {
    ...request,
    options: {
      ...request.options,
      refetchInterval: queryEnabled ? REFETCH_INTERVAL : false,
    },
  })

  useEffect(() => {
    if (
      resolvedData &&
      submission?.uuid === resolvedData.iterations[0].submissionUuid
    ) {
      setLatestIteration(resolvedData.iterations[0])
      setCheckStatus('success')
    } else {
      setCheckStatus('loading')
      setLatestIteration(undefined)
    }
  }, [resolvedData, submission])

  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { uuid: solution.uuid },
      (response) => {
        const lastIteration =
          response.iterations[response.iterations.length - 1]
        setLatestIteration(lastIteration)
        setCheckStatus(lastIteration.status)

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
        return <h3 className="text-h3">Checking for automated feedback...</h3>
      case 'no_automated_feedback':
        return (
          <h3 className="text-h3">
            There is no automated feedback for your solution
          </h3>
        )
      default:
        return (
          <div>
            <h3 className="text-h3">
              We&apos;ve found some automated feedback
            </h3>
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
            <div className="flex justify-around">
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
      shouldCloseOnOverlayClick={false}
    >
      {FeedbackContent()}
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
