import { useEffect } from 'react'
import useCustomFunctionStore from './store/customFunctionsStore'
import { CustomFunction } from './CustomFunctionEditor'

export function useSetupCustomFunctionStore({
  dependsOn,
  availableCustomFunctions,
  customFunction,
}: {
  dependsOn: ActiveCustomFunction[]
  availableCustomFunctions: AvailableCustomFunction[]
  customFunction: CustomFunction
}) {
  const {
    setCustomFunctionMetadataCollection,
    populateCustomFunctionsForInterpreter,
  } = useCustomFunctionStore()

  useEffect(() => {
    setCustomFunctionMetadataCollection(
      availableCustomFunctions.filter((cfn) => cfn.name !== customFunction.name)
    )
    populateCustomFunctionsForInterpreter(
      dependsOn.map((acf) => {
        return { ...acf, arity: acf.arity }
      })
    )
  }, [])
}
