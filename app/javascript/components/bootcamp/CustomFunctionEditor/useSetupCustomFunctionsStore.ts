import { useEffect } from 'react'
import useCustomFunctionStore from './store/customFunctionsStore'
import { CustomFunction } from './CustomFunctionEditor'

export function useSetupCustomFunctionStore({
  customFunction,
  customFunctions,
}: {
  customFunction: CustomFunction
  customFunctions: CustomFunctionsFromServer
}) {
  const { initializeCustomFunctions } = useCustomFunctionStore()

  useEffect(() => {
    // We don't want to include the custom function we're editing in the list of custom functions
    const customFunctionsButThisOne = customFunctions.forInterpreter.filter(
      (fn) => fn.name !== customFunction.name
    )

    const reviewedCustomFunctions = {
      ...customFunctions,
      forInterpreter: customFunctionsButThisOne,
    }

    initializeCustomFunctions(reviewedCustomFunctions)
  }, [])
}
