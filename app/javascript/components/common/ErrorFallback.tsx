import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function ErrorFallback({
  error,
  className,
}: {
  error: Error
  className?: string
}) {
  return (
    <div
      className={assembleClassNames(
        'c-alert--danger text-15 font-body mt-10 normal-case py-8 px-16',
        className
      )}
    >
      {error.message}
    </div>
  )
}
