import { useEffect } from 'react'
import useCustomFunctionStore from './store/customFunctionsStore'

export function useSetupCustomFunctionStore({
  dependsOn,
}: {
  dependsOn: string[]
}) {
  const { populateCustomFunctionsForInterpreter } = useCustomFunctionStore()

  useEffect(() => {
    // populateCustomFunctionsForInterpreter(
    //   dependsOn.map((acf) => {
    //     return { ...acf, arity: acf.arity }
    //   })
    // )
  }, [])
}
