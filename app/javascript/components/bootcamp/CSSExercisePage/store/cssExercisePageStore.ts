import { create } from 'zustand'

type CSSExercisePageStoreState = {
  diffMode: boolean
  toggleDiffMode: () => void
  curtainOpacity: number
  curtainMode: boolean
  toggleCurtainMode: () => void
  setCurtainOpacity: (curtainOpacity: number) => void
  panelSizes: {
    LHSWidth: number
    RHSWidth: number
  }
  setPanelSizes: (panelSizes: { LHSWidth: number; RHSWidth: number }) => void
  matchPercentage: number
  setMatchPercentage: (matchPercentage: number) => void
  assertionStatus: 'pass' | 'fail' | 'pending'
  setAssertionStatus: (assertionStatus: 'pass' | 'fail' | 'pending') => void
}

export const useCSSExercisePageStore = create<CSSExercisePageStoreState>(
  (set) => ({
    diffMode: false,
    curtainMode: false,
    toggleCurtainMode: () =>
      set((state) => ({ curtainMode: !state.curtainMode })),
    toggleDiffMode: () =>
      set((state) => ({
        diffMode: !state.diffMode,
        curtainOpacity: state.diffMode ? 1 : 0.3,
      })),
    curtainOpacity: 1,
    setCurtainOpacity: (curtainOpacity) => set({ curtainOpacity }),
    panelSizes: {
      LHSWidth: 800,
      RHSWidth: 800,
    },
    setPanelSizes: (panelSizes) => set({ panelSizes }),
    matchPercentage: 0,
    setMatchPercentage: (matchPercentage) => {
      if (matchPercentage === 100) {
        set({ assertionStatus: 'pass' })
      }
      set({ matchPercentage })
    },
    assertionStatus: 'pending',
    setAssertionStatus: (assertionStatus) => set({ assertionStatus }),
  })
)
