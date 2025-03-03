import React, { useContext } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { CustomFunctionsButton } from './CustomFunctionsButton'
import { ActiveToggleButton } from './ActiveToggleButton'
import { SolveExercisePageContext } from '../../SolveExercisePage/SolveExercisePageContextWrapper'
import { CustomFunctionEditorStoreContext } from '../CustomFunctionEditor'

export type StudentCodeGetter = () => string | undefined

function _Header({ handleSaveChanges }: { handleSaveChanges: () => void }) {
  const { customFunctionEditorStore } = useContext(
    CustomFunctionEditorStoreContext
  )
  const { clearResults } = customFunctionEditorStore()

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
        <ActiveToggleButton />
        <CustomFunctionsButton
          onChange={() => {
            clearResults()
          }}
        />
        <button className="btn-primary btn-xxs" onClick={handleSaveChanges}>
          Publish
        </button>

        <a
          href={links.customFnsDashboard}
          className={assembleClassNames('btn-secondary btn-xxs')}
        >
          Back to my stdlib
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
