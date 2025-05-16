import { create } from 'zustand'

type FrontendExercisePageStoreState = {
  isDiffActive: boolean
  toggleDiffActivity: () => void
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
    isDiffActive: false,
    toggleDiffActivity: () =>
      set((state) => ({ isDiffActive: !state.isDiffActive })),
    panelSizes: {
      LHSWidth: 800,
      RHSWidth: 800,
    },
    setPanelSizes: (panelSizes) => set({ panelSizes }),
    isFinishLessonModalOpen: false,
    setIsFinishLessonModalOpen: (value) =>
      set({ isFinishLessonModalOpen: value }),
  }))
