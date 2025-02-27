import { useEffect } from 'react'
import useCustomFunctionStore from './store/customFunctionsStore'

export function useSetupCustomFunctionStore({
  dependsOn,
  availableCustomFunctions,
}: {
  dependsOn: ActiveCustomFunction[]
  availableCustomFunctions: AvailableCustomFunction[]
}) {
  const {
    setCustomFunctionMetadataCollection,
    setCustomFunctionsForInterpreter,
  } = useCustomFunctionStore()

  useEffect(() => {
    setCustomFunctionMetadataCollection(availableCustomFunctions)
    setCustomFunctionsForInterpreter(
      dependsOn.map((acf) => {
        return { ...acf, arity: acf.fnArity }
      })
    )
  }, [])
}
