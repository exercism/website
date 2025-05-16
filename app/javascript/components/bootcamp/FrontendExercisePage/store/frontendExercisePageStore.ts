import { create } from 'zustand'

export type TabIndex = 'instructions' | 'output' | 'expected' | 'console'

type FrontendExercisePageStoreState = {
  isDiffActive: boolean
  toggleDiffActivity: () => void
  panelSizes: {
    LHSWidth: number
    RHSWidth: number
  }
  RHSActiveTab: TabIndex
  setRHSActiveTab: (tab: TabIndex) => void
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
    RHSActiveTab: 'output',
    setRHSActiveTab: (tab) => set({ RHSActiveTab: tab }),
    setPanelSizes: (panelSizes) => set({ panelSizes }),
    isFinishLessonModalOpen: false,
    setIsFinishLessonModalOpen: (value) =>
      set({ isFinishLessonModalOpen: value }),
  }))
