import { useResizablePanels } from '../SolveExercisePage/hooks/useResize'

export function useInitResizablePanels() {
  const {
    primarySize: TopHeight,
    secondarySize: BottomHeight,
    handleMouseDown: handleHeightChangeMouseDown,
  } = useResizablePanels({
    initialSize: 500,
    secondaryMinSize: 250,
    direction: 'vertical',
    localStorageId: 'frontend-training-page-lhs-height',
  })

  const {
    primarySize: LHSWidth,
    secondarySize: RHSWidth,
    handleMouseDown: handleWidthChangeMouseDown,
  } = useResizablePanels({
    initialSize: 800,
    direction: 'horizontal',
    localStorageId: 'solve-exercise-page-lhs',
  })

  return {
    TopHeight,
    BottomHeight,
    LHSWidth,
    RHSWidth,
    handleHeightChangeMouseDown,
    handleWidthChangeMouseDown,
  }
}
