import React, { useCallback } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ToggleButton } from '@/components/common/ToggleButton'
import { useFrontendTrainingPageStore } from './store/frontendTrainingPageStore'

export type StudentCodeGetter = () => string | undefined

function _Header({ onCompare }: { onCompare: () => void }) {
  const {
    diffMode,
    curtainMode,
    toggleCurtainMode,
    toggleDiffMode: toggleDiffModeState,
    setCurtainOpacity,
  } = useFrontendTrainingPageStore()

  const toggleDiffMode = useCallback((diffState: boolean) => {
    toggleDiffModeState()
    diffState ? setCurtainOpacity(1) : setCurtainOpacity(0.3)
  }, [])

  return (
    <div className="page-header justify-between">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>

      <div className="flex items-center gap-8">
        <ToggleButton
          className="w-fit"
          checked={curtainMode}
          onToggle={toggleCurtainMode}
        />
        <ToggleButton
          className="w-fit"
          checked={diffMode}
          onToggle={() => toggleDiffMode(diffMode)}
        />
        <button className="btn-primary btn-xxs" onClick={onCompare}>
          Compare
        </button>

        <a href={''} className={assembleClassNames('btn-secondary btn-xxs')}>
          Back
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
