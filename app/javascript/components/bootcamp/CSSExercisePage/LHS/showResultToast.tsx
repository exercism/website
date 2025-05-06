import React from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { CheckResult } from '../checks/runCssChecks'
import { PASS_THRESHOLD } from '../store/cssExercisePageStore'

export function showResultToast(
  status: 'pass' | 'fail',
  percentage: number,
  firstFailingCheck?: CheckResult | null
) {
  toast.custom(
    (t) => (
      <div
        className={assembleClassNames(
          t.visible ? 'animate-slideIn' : 'animate-slideOut',
          status === 'pass' ? 'border-successColor' : 'border-danger',
          'border-2 flex bg-white shadow-base text-14 rounded-5 p-8 gap-8 items-center'
        )}
      >
        {/*
          We always only show one message. 
          Pixel-matching is top priority, then other checks' error message. 
          Otherwise show a success message.
         */}
        {percentage < PASS_THRESHOLD ? (
          <TextBlock
            status={status}
            text={`Your output isn't exactly the same as the target yet (${percentage}%).`}
          />
        ) : firstFailingCheck ? (
          <TextBlock
            status={status}
            text={firstFailingCheck.error_html || ''}
          />
        ) : (
          <TextBlock status={status} text="Congrats! All checks are passing!" />
        )}

        <button
          className="btn-xs btn-enhanced"
          onClick={() => toast.dismiss(t.id)}
        >
          Got it
        </button>
      </div>
    ),
    { duration: 6000 }
  )
}

function TextBlock({
  text,
  status,
}: {
  text: string
  status: 'pass' | 'fail'
}) {
  return (
    <div
      className={assembleClassNames(
        'font-semibold',
        status === 'pass' ? 'text-darkSuccessGreen' : 'text-danger'
      )}
    >
      {text}
    </div>
  )
}
