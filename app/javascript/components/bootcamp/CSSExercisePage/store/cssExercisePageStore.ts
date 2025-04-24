import { create } from 'zustand'
import { launchConfetti } from '../../JikiscriptExercisePage/Tasks/launchConfetti'
import { ChecksResult } from '../utils/runCheckFunctions'

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
  updateAssertionStatus: (newStatus: 'pass' | 'fail') => void
  isFinishLessonModalOpen: boolean
  setIsFinishLessonModalOpen: (value: boolean) => void
  wasFinishLessonModalShown: boolean
  setWasFinishLessonModalShown: (value: boolean) => void
  checksResult: ChecksResult[]
  setChecksResult: (checksResult: ChecksResult[]) => void
}

export const useCSSExercisePageStore = create<CSSExercisePageStoreState>(
  (set) => ({
    diffMode: false,
    curtainMode: false,
    toggleCurtainMode: () =>
      set((state) => ({ curtainMode: !state.curtainMode, diffMode: false })),
    toggleDiffMode: () =>
      set((state) => ({
        diffMode: !state.diffMode,
        curtainMode: false,
      })),
    curtainOpacity: 1,
    setCurtainOpacity: (curtainOpacity) => set({ curtainOpacity }),
    panelSizes: {
      LHSWidth: 800,
      RHSWidth: 800,
    },
    setPanelSizes: (panelSizes) => set({ panelSizes }),
    checksResult: [],
    setChecksResult: (checksResult) => set({ checksResult }),

    updateAssertionStatus: (newStatus) => {
      if (newStatus === 'pass') {
        set((state) => {
          const newState: {
            assertionStatus: CSSExercisePageStoreState['assertionStatus']
          } = { assertionStatus: 'pass' }

          if (!state.wasFinishLessonModalShown) {
            Object.assign(newState, {
              isFinishLessonModalOpen: true,
              wasFinishLessonModalShown: true,
            })
            launchConfetti()
          }
          return newState
        })
      } else {
        set({ assertionStatus: 'fail' })
      }
    },
    matchPercentage: 0,
    setMatchPercentage: (matchPercentage) => {
      if (matchPercentage === 100) {
        set((state) => {
          const newState: {
            assertionStatus: CSSExercisePageStoreState['assertionStatus']
          } = { assertionStatus: 'pass' }

          if (!state.wasFinishLessonModalShown) {
            Object.assign(newState, {
              isFinishLessonModalOpen: true,
              wasFinishLessonModalShown: true,
            })
            launchConfetti()
          }
          return newState
        })
      }
      set({ matchPercentage })
    },
    assertionStatus: 'pending',
    isFinishLessonModalOpen: false,
    setIsFinishLessonModalOpen: (value) =>
      set({ isFinishLessonModalOpen: value }),
    wasFinishLessonModalShown: false,
    setWasFinishLessonModalShown: (value) =>
      set({ wasFinishLessonModalShown: value }),
  })
)
