import { useEffect, useState } from 'react'
import { CustomFunction } from './CustomFunctionEditor'
import { useLocalStorage } from '@uidotdev/usehooks'

export type CustomTest = { codeRun: string; expected: string; uuid: string }[]

export function useFunctionDetailsManager(customFunction: CustomFunction) {
  const [detailsLocalStorageValue, setDetailsLocalStorageValue] =
    useLocalStorage(`custom-fn-details-${customFunction.uuid}`, {
      name: customFunction.name,
      description: customFunction.description,
    })
  const [name, setName] = useState(detailsLocalStorageValue.name)
  const [isActivated, setIsActivated] = useState<boolean>(customFunction.active)
  const [description, setDescription] = useState(
    detailsLocalStorageValue.description
  )

  useEffect(() => {
    setDetailsLocalStorageValue({ name, description })
  }, [name, description])

  return {
    name,
    setName,
    description,
    setDescription,
    isActivated,
    setIsActivated,
  }
}
