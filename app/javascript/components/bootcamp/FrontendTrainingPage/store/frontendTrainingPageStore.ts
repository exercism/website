import { create } from 'zustand'

type FrontendTrainingPageStoreState = {
  diffMode: boolean
  toggleDiffMode: () => void
  curtainOpacity: number
  setCurtainOpacity: (curtainOpacity: number) => void
}

export const useFrontendTrainingPageStore =
  create<FrontendTrainingPageStoreState>((set) => ({
    diffMode: false,
    toggleDiffMode: () => set((state) => ({ diffMode: !state.diffMode })),
    curtainOpacity: 1,
    setCurtainOpacity: (curtainOpacity) => set({ curtainOpacity }),
  }))
