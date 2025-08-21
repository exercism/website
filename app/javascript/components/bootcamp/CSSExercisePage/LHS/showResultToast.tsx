// i18n-key-prefix: showResultToast
// i18n-namespace: components/bootcamp/CSSExercisePage/LHS
import React from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import {
  AssertionStatus,
  GRACE_THRESHOLD,
  PASS_THRESHOLD,
} from '../store/cssExercisePageStore'
import { CheckResult } from '../checks/runChecks'
import GraphicalIcon from '@/components/common/GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

const STATUS_COLORS: Record<AssertionStatus, { border: string; text: string }> =
  {
    pass: {
      border: 'var(--successColor)',
      text: '#2E8C70',
    },
    fail: {
      border: '#D85050',
      text: '#D85050',
    },
    grace: {
      border: '#DC8604',
      text: '#DC8604',
    },
  }

export function showResultToast(
  status: AssertionStatus,
  percentage: number,
  firstFailingCheck?: CheckResult | null
) {
  toast.custom(
    (t) => (
      <div
        style={{ borderColor: STATUS_COLORS[status].border }}
        className={assembleClassNames(
          t.visible ? 'animate-slideIn' : 'animate-slideOut',
          'max-w-[500px]',
          `border-${STATUS_COLORS[status].border}`,
          'border-1 flex justify-between bg-white shadow-base text-14 rounded-8 p-8 gap-8 items-center relative'
        )}
      >
        <ToastText
          percentage={percentage}
          status={status}
          firstFailingCheck={firstFailingCheck}
        />
        <button
          className="rounded-circle bg-bootcamp-light-purple p-4 self-start"
          onClick={() => toast.dismiss(t.id)}
        >
          <GraphicalIcon icon="close" height={12} width={12} />
        </button>
      </div>
    ),
    { duration: 6000 }
  )
}

function ToastText({
  status,
  percentage,
  firstFailingCheck,
}: {
  status: AssertionStatus
  percentage: number
  firstFailingCheck?: CheckResult | null
}) {
  const { t } = useAppTranslation('components/bootcamp/CSSExercisePage/LHS')

  if (firstFailingCheck) {
    return (
      <TextBlock
        status={status}
        textHtml={firstFailingCheck.error_html || ''}
      />
    )
  }

  if (percentage < GRACE_THRESHOLD) {
    return (
      <TextBlock
        status={status}
        textHtml={t('showResultToast.outputNotSame', { percentage })}
      />
    )
  }

  if (percentage < PASS_THRESHOLD) {
    return (
      <div
        style={{ color: STATUS_COLORS[status].text }}
        className={assembleClassNames('font-medium px-8 py-4')}
      >
        <p className="text-14 leading-160">
          <Trans
            i18nKey="showResultToast.completeExercise"
            values={{ percentage }}
            components={{
              strong: <strong />,
            }}
          />
        </p>
      </div>
    )
  }

  return (
    <TextBlock
      status={status}
      textHtml={t('showResultToast.congratsAllChecksPassing')}
    />
  )
}

function TextBlock({
  textHtml,
  status,
}: {
  textHtml: string
  status: AssertionStatus
}) {
  return (
    <div
      style={{ color: STATUS_COLORS[status].text }}
      className={assembleClassNames('font-medium px-8 py-4')}
      dangerouslySetInnerHTML={{ __html: textHtml }}
    />
  )
}
