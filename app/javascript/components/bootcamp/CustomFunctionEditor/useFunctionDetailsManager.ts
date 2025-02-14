import { useState } from 'react'

export type CustomTest = { codeRun: string; expected: string; uuid: string }[]

export function useFunctionDetailsManager() {
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')

  return { name, setName, description, setDescription }
}
