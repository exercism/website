import React, { useCallback } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ResetButton } from './ResetButton'

export type StudentCodeGetter = () => string | undefined

function _Header() {
  return (
    <div className="page-header justify-between">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>

      <div className="flex items-center gap-8">
        <ResetButton />
        <button className="btn-primary btn-xxs" onClick={() => {}}>
          Complete Exercise
        </button>

        <a href={''} className={assembleClassNames('btn-secondary btn-xxs')}>
          Back
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
