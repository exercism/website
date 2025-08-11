import React from 'react'
import { IterationStatus } from '../types'
import { GraphicalIcon } from '.'
import { useAppTranslation } from '@/i18n/useAppTranslation'

function Content({ status }: { status: string }) {
  const { t } = useAppTranslation(
    'components/common/ProcessingStatusSummary.tsx'
  )

  switch (status) {
    case 'processing':
      return (
        <>
          <GraphicalIcon icon="spinner" className="animate-spin-slow" />
          <div className="--status">{t('processing')}</div>
        </>
      )
    case 'failed':
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">{t('failed')}</div>
        </>
      )
    default:
      return (
        <>
          <div role="presentation" className="--dot"></div>
          <div className="--status">{t('passed')}</div>
        </>
      )
  }
}

function transformStatus(iterationStatus: IterationStatus): string {
  switch (iterationStatus) {
    case IterationStatus.TESTING:
    case IterationStatus.ANALYZING:
      return 'processing'
    case IterationStatus.TESTS_FAILED:
      return 'failed'
    default:
      return 'passed'
  }
}

export function ProcessingStatusSummary({
  iterationStatus,
}: {
  iterationStatus: IterationStatus
}): JSX.Element {
  const { t } = useAppTranslation(
    'components/common/ProcessingStatusSummary.tsx'
  )

  if (
    iterationStatus == IterationStatus.DELETED ||
    iterationStatus == IterationStatus.UNTESTED
  ) {
    return <></>
  }
  const status = transformStatus(iterationStatus)

  return (
    <div
      className={`c-iteration-processing-status --${status}`}
      role="status"
      aria-label={t('processingStatus')}
    >
      <Content status={status} />
    </div>
  )
}
