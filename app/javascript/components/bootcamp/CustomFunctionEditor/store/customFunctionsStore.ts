import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type CustomFunctionMetadata = {
  slug: string
  name: string
  description: string
}

export type CustomFunctionForInterpreter = {
  code: string
  arity: number
  name: string
  slug: string
}

type CustomFunctionsStore = {
  customFunctionMetadataCollection: CustomFunctionMetadata[]
  setCustomFunctionMetadataCollection: (
    customFunctionMetadataCollection: CustomFunctionMetadata[]
  ) => void
  customFunctionsForInterpreter: CustomFunctionForInterpreter[]
  addCustomFunctionsForInterpreter: (
    customFunctionsForInterpreter: CustomFunctionForInterpreter
  ) => void
  removeCustomFunctionsForInterpreter: (slug: string) => void
}

const useCustomFunctionStore = create<CustomFunctionsStore>()(
  persist(
    (set) => ({
      customFunctionMetadataCollection: [],
      setCustomFunctionMetadataCollection: (
        customFunctionMetadataCollection
      ) => {
        set({ customFunctionMetadataCollection })
      },
      customFunctionsForInterpreter: [],
      addCustomFunctionsForInterpreter: (customFunctionsForInterpreter) => {
        set((state) => {
          const customFnsForInterpreter = [
            ...state.customFunctionsForInterpreter,
            customFunctionsForInterpreter,
          ]
          return {
            customFunctionsForInterpreter: customFnsForInterpreter,
          }
        })
      },
      removeCustomFunctionsForInterpreter: (slug) => {
        set((state) => {
          const customFnsForInterpreter =
            state.customFunctionsForInterpreter.filter((fn) => fn.slug !== slug)

          return {
            customFunctionsForInterpreter: customFnsForInterpreter,
          }
        })
      },
    }),
    { name: 'custom-functions-store' }
  )
)

export default useCustomFunctionStore
