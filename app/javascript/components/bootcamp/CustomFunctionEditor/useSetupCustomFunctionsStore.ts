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
    setCustomFunctionsForInterpreter,
  } = useCustomFunctionStore()

  useEffect(() => {
    setCustomFunctionMetadataCollection(
      availableCustomFunctions.filter((cfn) => cfn.name !== customFunction.name)
    )
    setCustomFunctionsForInterpreter(
      dependsOn.map((acf) => {
        return { ...acf, arity: acf.arity }
      })
    )
  }, [])
}
