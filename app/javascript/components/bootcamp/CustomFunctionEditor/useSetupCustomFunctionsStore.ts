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
    const filteredInterpreterFunctions = customFunctions.forInterpreter
      // We don't want to include the custom function we're editing in the list of custom functions
      .filter((fn) => fn.name !== customFunction.name)
      .map((fn) => {
        // We want to know if a custom function depends on what we currently have in the editor
        if (fn.dependencies.includes(customFunction.name)) {
          return {
            ...fn,
            dependsOnCurrentFunction: true,
          }
        }
        return fn
      })
      .sort((a, b) => {
        return (
          Number(!!a.dependsOnCurrentFunction) -
          Number(!!b.dependsOnCurrentFunction)
        )
      })

    const updatedCustomFunctions = {
      ...customFunctions,
      forInterpreter: filteredInterpreterFunctions,
    }

    initializeCustomFunctions(updatedCustomFunctions)
  }, [])
}
