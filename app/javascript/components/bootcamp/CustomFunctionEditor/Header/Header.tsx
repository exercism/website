import React from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { SettingsButton } from './SettingsButton'

export type StudentCodeGetter = () => string | undefined

function _Header({
  links,
  handleSaveChanges,
  someTestsAreFailing,
}: {
  links: Record<any, any>
  handleSaveChanges: () => void
  someTestsAreFailing: boolean
}) {
  return (
    <div className="page-header justify-between">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>

      <div className="flex items-center gap-8">
        <button
          className="btn-primary btn-xxs"
          disabled={someTestsAreFailing}
          onClick={handleSaveChanges}
        >
          Save
        </button>

        <a
          href={links.customFunctionsIndex}
          className={assembleClassNames('btn-secondary btn-xxs')}
        >
          Back to my stdlib
        </a>
        <SettingsButton />
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
