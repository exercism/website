import { create } from 'zustand'

export type TabIndex = 'instructions' | 'output' | 'expected' | 'console'

type FrontendExercisePageStoreState = {
  logs: unknown[][]
  setLogs: (logs: unknown[][] | ((prev: unknown[][]) => unknown[][])) => void

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
    logs: [],
    setLogs: (logs) =>
      set((state) => ({
        logs: typeof logs === 'function' ? logs(state.logs) : logs,
      })),
    isDiffActive: false,
    toggleDiffActivity: () =>
      set((state) => ({ isDiffActive: !state.isDiffActive })),
    panelSizes: {
      LHSWidth: 800,
      RHSWidth: 800,
    },
    RHSActiveTab: 'instructions',
    setRHSActiveTab: (tab) => set({ RHSActiveTab: tab }),
    setPanelSizes: (panelSizes) => set({ panelSizes }),
    isFinishLessonModalOpen: false,
    setIsFinishLessonModalOpen: (value) =>
      set({ isFinishLessonModalOpen: value }),
  }))
