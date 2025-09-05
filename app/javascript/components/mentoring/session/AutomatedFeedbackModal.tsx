import React from 'react'
import { useRequestQuery } from '@/hooks/request-query'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { Icon, GraphicalIcon } from '@/components/common'
import { AnalyzerFeedback } from '@/components/student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '@/components/student/iterations-list/RepresenterFeedback'
import type {
  AnalyzerFeedback as AnalyzerFeedbackProps,
  Iteration,
  MentorSessionTrack,
  RepresenterFeedback as RepresenterFeedbackProps,
} from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation()
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
        <header>
          <GraphicalIcon icon="automation" />
          <div className="info">
            <h2 className="text-h5">
              {t(
                'components.mentoring.session.automatedFeedbackModal.automatedAnalysis'
              )}
            </h2>
            <div className="text-textColor6 text-15 leading-150">
              {t(
                'components.mentoring.session.automatedFeedbackModal.forIteration',
                { iteration: iteration.idx }
              )}
            </div>
          </div>
        </header>
        {data ? (
          <div className="feedback">
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

const LoadingComponent = (): JSX.Element => {
  const { t } = useAppTranslation()
  return (
    <Icon
      icon="spinner"
      alt={t(
        'components.mentoring.session.automatedFeedbackModal.loadingAutomatedFeedback'
      )}
    />
  )
}
