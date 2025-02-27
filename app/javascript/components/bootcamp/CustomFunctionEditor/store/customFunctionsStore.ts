import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type CustomFunctionMetadata = {
  uuid: string
  name: string
  description: string
}

export type CustomFunctionForInterpreter = {
  code: string
  arity: number
  name: string
  uuid: string
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
  removeCustomFunctionsForInterpreter: (uuid: string) => void
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
      removeCustomFunctionsForInterpreter: (uuid) => {
        set((state) => {
          const customFnsForInterpreter =
            state.customFunctionsForInterpreter.filter((fn) => fn.uuid !== uuid)

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
