import React, { useContext } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { SettingsButton } from './SettingsButton'
import { SolveExercisePageContext } from '../../SolveExercisePage/SolveExercisePageContextWrapper'

export type StudentCodeGetter = () => string | undefined

function _Header({
  handleSaveChanges,
  someTestsAreFailing,
}: {
  handleSaveChanges: () => void
  someTestsAreFailing: boolean
}) {
  const { links } = useContext(SolveExercisePageContext)
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
          href={links.customFnsDashboard}
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
