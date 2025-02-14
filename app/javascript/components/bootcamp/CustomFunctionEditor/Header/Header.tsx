import React from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'

export type StudentCodeGetter = () => string | undefined

function _Header({ links }: { links: Record<any, any> }) {
  return (
    <div className="page-header justify-between">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>

      <a
        href={links.customFunctionsIndex}
        className={assembleClassNames('btn-secondary btn-xxs')}
      >
        Back to my stdlib
      </a>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
