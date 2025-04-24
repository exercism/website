import React from 'react'
import toast from 'react-hot-toast'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { CheckResult } from '../utils/runCheckFunctions'

export function showResultToast(
  status: 'pass' | 'fail',
  percentage: number,
  firstFailingCheck?: CheckResult | undefined
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
        <div className="flex flex-col gap-4">
          <div
            className={assembleClassNames(
              'font-semibold',
              status === 'pass' ? 'text-darkSuccessGreen' : 'text-danger'
            )}
          >
            {firstFailingCheck
              ? firstFailingCheck.error_html
              : 'All checks are passing!'}
          </div>
          <div className="font-semibold">Match percentage: {percentage}%</div>
        </div>

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
