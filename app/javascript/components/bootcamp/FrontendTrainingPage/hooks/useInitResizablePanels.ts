import { useResizablePanels } from '../../SolveExercisePage/hooks/useResize'
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
    localStorageId: 'solve-exercise-page-lhs',
    onChange: (panelSizes) => {
      setPanelSizes({
        LHSWidth: panelSizes.primarySize,
        RHSWidth: panelSizes.secondarySize,
      })
    },
  })

  return {
    LHSWidth,
    RHSWidth,
    handleWidthChangeMouseDown,
  }
}
