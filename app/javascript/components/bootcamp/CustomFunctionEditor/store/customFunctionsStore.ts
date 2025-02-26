import { createStoreWithMiddlewares } from '../../SolveExercisePage/store/utils'

export type CustomFunctionMetadata = {
  slug: string
  name: string
  description: string
}

export type CustomFunctionForInterpreter = {
  code: string
  fn_arity: number
  fn_name: string
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

const useCustomFunctionStore = createStoreWithMiddlewares<CustomFunctionsStore>(
  (set) => ({
    customFunctionMetadataCollection: [],
    setCustomFunctionMetadataCollection: (customFunctionMetadataCollection) => {
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
        console.log('inside remover', customFnsForInterpreter)

        return {
          customFunctionsForInterpreter: customFnsForInterpreter,
        }
      })
    },
  }),
  'CustomFunctionsStore'
)

export default useCustomFunctionStore
