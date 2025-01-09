import React, { useCallback } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'

export type StudentCodeGetter = () => string | undefined

function _Header({
  links,
  savingStateLabel,
}: { savingStateLabel: string } & Pick<DrawingPageProps, 'links'>) {
  return (
    <div className="page-header">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>
      <div className="ml-auto flex items-center">
        {savingStateLabel && (
          <span className="text-xs text-gray-500 font-semibold mr-4">
            {savingStateLabel}
          </span>
        )}

        <a
          href={links.drawingsIndex}
          className={assembleClassNames('btn-secondary btn-xxs ml-8')}
        >
          Back
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
