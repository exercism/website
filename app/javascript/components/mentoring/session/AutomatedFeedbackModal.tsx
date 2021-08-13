import React from 'react'
import { FetchingBoundary } from '../../FetchingBoundary'
import { Modal, ModalProps } from '../../modals/Modal'
import { Icon } from '../../common'
import { useRequestQuery } from '../../../hooks/request-query'
import {
  AnalyzerFeedback as AnalyzerFeedbackProps,
  Iteration,
  MentorSessionTrack,
  RepresenterFeedback as RepresenterFeedbackProps,
} from '../../types'
import { AnalyzerFeedback } from '../../student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '../../student/iterations-list/RepresenterFeedback'
import { SessionInfo } from './SessionInfo'

const DEFAULT_ERROR = new Error('Unable to load automated feedback')

type APIResponse = {
  automatedFeedback: {
    representerFeedback?: RepresenterFeedbackProps
    analyzerFeedback?: AnalyzerFeedbackProps
    links: {
      info: string
    }
    track: MentorSessionTrack
  }
}

export const AutomatedFeedbackModal = ({
  iteration,
  ...props
}: Omit<ModalProps, 'className'> & { iteration: Iteration }): JSX.Element => {
  const { data, status, error } = useRequestQuery<APIResponse>(
    ['automated-feedback', iteration.links.automatedFeedback],
    { endpoint: iteration.links.automatedFeedback, options: {} }
  )
  return (
    <Modal {...props} className="m-automated-feedback">
      <FetchingBoundary
        LoadingComponent={LoadingComponent}
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        {data ? (
          <div>
            {data.automatedFeedback.analyzerFeedback ? (
              <AnalyzerFeedback
                track={data.automatedFeedback.track}
                {...data.automatedFeedback.analyzerFeedback}
                automatedFeedbackInfoLink={data.automatedFeedback.links.info}
              />
            ) : null}
            {data.automatedFeedback.representerFeedback ? (
              <RepresenterFeedback
                {...data.automatedFeedback.representerFeedback}
              />
            ) : null}
          </div>
        ) : null}
      </FetchingBoundary>
    </Modal>
  )
}

const LoadingComponent = () => (
  <Icon icon="spinner" alt="Loading automated feedback" />
)
