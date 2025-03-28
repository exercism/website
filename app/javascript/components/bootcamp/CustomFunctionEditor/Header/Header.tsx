import React, { useContext } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { CustomFunctionsButton } from './CustomFunctionsButton'
import { ActiveToggleButton } from './ActiveToggleButton'
import { JikiscriptExercisePageContext } from '../../JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'
import customFunctionEditorStore from '../store/customFunctionEditorStore'
import { DeleteFunctionButton } from '../DeleteFunctionButton'

export type StudentCodeGetter = () => string | undefined

function _Header({ handleSaveChanges }: { handleSaveChanges: () => void }) {
  const { clearResults, customFunctionName, isPredefined } =
    customFunctionEditorStore()

  const { links } = useContext(JikiscriptExercisePageContext)
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
        <button
          disabled={customFunctionName.length === 0}
          className="btn-primary btn-xxs"
          onClick={handleSaveChanges}
        >
          Save Changes
        </button>
        <DeleteFunctionButton predefined={isPredefined} />
        <a
          href={links.customFnsDashboard}
          className={assembleClassNames('btn-secondary btn-xxs')}
        >
          Close
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
