import { useLayoutEffect } from 'react'
import { useResizablePanels } from '../../JikiscriptExercisePage/hooks/useResize'
import { useFrontendExercisePageStore } from '../store/frontendExercisePageStore'

export function useInitResizablePanels() {
  const { setPanelSizes } = useFrontendExercisePageStore()
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
