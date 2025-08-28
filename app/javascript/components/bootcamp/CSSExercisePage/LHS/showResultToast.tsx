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
        textHtml={`Your output isn't exactly the same as the target yet (${percentage}%).`}
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
          You're currently at {percentage}%. You can <strong> complete </strong>{' '}
          the exercise if you have invested as much energy as you want to into
          it. But you might like to try to get to <strong>100%</strong> still!
        </p>
      </div>
    )
  }

  return (
    <TextBlock status={status} textHtml="Congrats! All checks are passing!" />
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
