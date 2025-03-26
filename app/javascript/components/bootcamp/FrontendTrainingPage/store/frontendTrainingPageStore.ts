import { create } from 'zustand'
import { Handler } from '../../SolveExercisePage/CodeMirror/CodeMirror'

type FrontendTrainingPageStoreState = {
  diffMode: boolean
  toggleDiffMode: () => void
  curtainOpacity: number
  setCurtainOpacity: (curtainOpacity: number) => void
  panelSizes: {
    LHSWidth: number
    RHSWidth: number
  }
  setPanelSizes: (panelSizes: { LHSWidth: number; RHSWidth: number }) => void
}

export const useFrontendTrainingPageStore =
  create<FrontendTrainingPageStoreState>((set) => ({
    diffMode: false,
    toggleDiffMode: () => set((state) => ({ diffMode: !state.diffMode })),
    curtainOpacity: 1,
    setCurtainOpacity: (curtainOpacity) => set({ curtainOpacity }),
    panelSizes: {
      LHSWidth: 800,
      RHSWidth: 800,
    },
    setPanelSizes: (panelSizes) => set({ panelSizes }),
  }))
