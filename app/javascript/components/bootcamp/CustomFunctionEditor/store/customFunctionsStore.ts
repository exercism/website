import { create } from 'zustand'

export type CustomFunctionMetadata = {
  name: string
  description: string
}

export type CustomFunctionForInterpreter = {
  code: string
  arity: number
  name: string
  fnName: string
}

type CustomFunctionsStore = {
  customFunctionMetadataCollection: CustomFunctionMetadata[]
  setCustomFunctionMetadataCollection: (
    customFunctionMetadataCollection: CustomFunctionMetadata[]
  ) => void
  customFunctionsForInterpreter: CustomFunctionForInterpreter[]
  setCustomFunctionsForInterpreter: (
    customFunctionsForInterpreter: CustomFunctionForInterpreter[]
  ) => void
  addCustomFunctionsForInterpreter: (
    customFunctionsForInterpreter: CustomFunctionForInterpreter
  ) => void
  removeCustomFunctionsForInterpreter: (name: string) => void
}

const useCustomFunctionStore = create<CustomFunctionsStore>((set) => ({
  customFunctionMetadataCollection: [],
  setCustomFunctionMetadataCollection: (customFunctionMetadataCollection) => {
    set({ customFunctionMetadataCollection })
  },
  setCustomFunctionsForInterpreter: (customFunctionsForInterpreter) => {
    set({ customFunctionsForInterpreter })
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
  removeCustomFunctionsForInterpreter: (name) => {
    set((state) => {
      const customFnsForInterpreter =
        state.customFunctionsForInterpreter.filter((fn) => fn.name !== name)

      return {
        customFunctionsForInterpreter: customFnsForInterpreter,
      }
    })
  },
}))

export default useCustomFunctionStore
