import { create } from 'zustand'

type FrontendExercisePageStoreState = {
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
  isFinishLessonModalOpen: boolean
  setIsFinishLessonModalOpen: (value: boolean) => void
}

export const useFrontendExercisePageStore =
  create<FrontendExercisePageStoreState>((set) => ({
    diffMode: false,
    curtainMode: false,
    toggleCurtainMode: () =>
      set((state) => ({ curtainMode: !state.curtainMode })),
    toggleDiffMode: () => set((state) => ({ diffMode: !state.diffMode })),
    curtainOpacity: 1,
    setCurtainOpacity: (curtainOpacity) => set({ curtainOpacity }),
    panelSizes: {
      LHSWidth: 800,
      RHSWidth: 800,
    },
    setPanelSizes: (panelSizes) => set({ panelSizes }),
    isFinishLessonModalOpen: false,
    setIsFinishLessonModalOpen: (value) =>
      set({ isFinishLessonModalOpen: value }),
  }))
