import { create } from 'zustand'
import { launchConfetti } from '../../JikiscriptExercisePage/Tasks/launchConfetti'
import { ChecksResult } from '../checks/runChecks'

export const PASS_THRESHOLD = 99
export const GRACE_THRESHOLD = 96

export type AssertionStatus = 'pass' | 'fail' | 'grace'

type CSSExercisePageStoreState = {
  isDiffModeOn: boolean
  diffMode: 'gradual' | 'binary'
  toggleDiffMode: () => void
  toggleIsDiffModeOn: () => void
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
  assertionStatus: AssertionStatus
  setAssertionStatus: (assertionStatus: AssertionStatus) => void
  updateAssertionStatus: (newStatus: AssertionStatus) => void
  isFinishLessonModalOpen: boolean
  setIsFinishLessonModalOpen: (value: boolean) => void
  wasFinishLessonModalShown: boolean
  setWasFinishLessonModalShown: (value: boolean) => void
  checksResult: ChecksResult[]
  setChecksResult: (checksResult: ChecksResult[]) => void
  studentCodeHash: string
  setStudentCodeHash: (studentCodeHash: string) => void
}

export const useCSSExercisePageStore = create<CSSExercisePageStoreState>(
  (set, get) => ({
    isDiffModeOn: false,
    diffMode: 'gradual',
    toggleDiffMode: () => {
      set((state) => ({
        diffMode: state.diffMode === 'gradual' ? 'binary' : 'gradual',
        isDiffModeOn: true,
        curtainMode: false,
      }))
    },

    curtainMode: false,
    toggleCurtainMode: () =>
      set((state) => ({
        curtainMode: !state.curtainMode,
        isDiffModeOn: false,
      })),
    toggleIsDiffModeOn: () =>
      set((state) => ({
        isDiffModeOn: !state.isDiffModeOn,
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
    assertionStatus: 'fail',
    setAssertionStatus: (assertionStatus) => {
      set({ assertionStatus })
    },

    updateAssertionStatus: (newStatus) => {
      const currentAssertionStatus = get().assertionStatus

      // if it's already passing, we won't degrade it, and won't show modals anymore
      if (currentAssertionStatus === 'pass') return

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
      } else set({ assertionStatus: newStatus })
    },
    matchPercentage: 0,
    setMatchPercentage: (matchPercentage) => {
      if (matchPercentage >= PASS_THRESHOLD) {
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
    isFinishLessonModalOpen: false,
    setIsFinishLessonModalOpen: (value) =>
      set({ isFinishLessonModalOpen: value }),
    wasFinishLessonModalShown: false,
    setWasFinishLessonModalShown: (value) =>
      set({ wasFinishLessonModalShown: value }),
    studentCodeHash: '',
    setStudentCodeHash: (studentCodeHash) => set({ studentCodeHash }),
  })
)
