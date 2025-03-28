import { useLayoutEffect } from 'react'
import { useResizablePanels } from '../../JikiscriptExercisePage/hooks/useResize'
import { useFrontendTrainingPageStore } from '../store/frontendTrainingPageStore'

export function useInitResizablePanels() {
  const { setPanelSizes } = useFrontendTrainingPageStore()
  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown: handleWidthChangeMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'frontend-training-page-size',
    onChange: (panelSizes) => {
      setPanelSizes({
        LHSWidth: panelSizes.primarySize,
        RHSWidth: panelSizes.secondarySize,
      })
    },
  })

  // load in the stored panel sizes before mount
  useLayoutEffect(() => {
    setPanelSizes({
      LHSWidth,
      RHSWidth,
    })
  }, [])

  return {
    LHSWidth,
    RHSWidth,
    handleWidthChangeMouseDown,
  }
}
