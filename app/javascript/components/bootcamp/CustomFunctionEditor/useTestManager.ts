import { useState, useCallback, useEffect, useMemo } from 'react'
import { v4 as uuid } from 'uuid'
import { CustomFunction } from './CustomFunctionEditor'
import { useLocalStorage } from '@uidotdev/usehooks'
import { Frame } from '@/interpreter/frames'

export type CustomTests = { args: string; expected: string; uuid: string }[]

export type Results = Record<
  string,
  { actual: any; frames: Frame[]; pass: boolean }
>

export function useTestManager(customFunction: CustomFunction) {
  const [testsLocalStorageValue, setTestsLocalStorageValue] = useLocalStorage(
    `custom-fn-tests-${customFunction.uuid}`,
    { tests: customFunction.tests }
  )
  const [tests, setTests] = useState<CustomTests>(
    testsLocalStorageValue.tests ?? []
  )

  const [inspectedTest, setInspectedTest] = useState<string>('')

  const [results, setResults] = useState<Results>({})

  const areAllTestsPassing = useMemo(() => {
    return Object.values(results).every((result) => result.pass)
  }, [results])

  useEffect(() => {
    setTestsLocalStorageValue({ tests })
  }, [tests])

  const [testBeingEdited, setTestBeingEdited] = useState<string>()

  const handleAddNewTest = useCallback(() => {
    const newUuid = uuid()
    setTests((tests) => [
      ...tests,
      {
        args: '',
        expected: '',
        uuid: newUuid,
      },
    ])

    setInspectedTest(newUuid)

    setTestBeingEdited(newUuid)
  }, [])

  const handleDeleteTest = useCallback((uuid: string) => {
    setTests((tests) => tests.filter((t) => t.uuid !== uuid))
  }, [])

  const handleUpdateTest = useCallback(
    (uuid: string, newParams: string, newExpected: string) => {
      setTests((tests) =>
        tests.map((test) =>
          test.uuid === uuid
            ? { ...test, args: newParams, expected: newExpected }
            : test
        )
      )
      setTestBeingEdited(undefined)
    },
    []
  )

  const handleCancelEditing = useCallback(() => {
    setTestBeingEdited(undefined)
  }, [])

  return {
    tests,
    testBeingEdited,
    results,
    inspectedTest,
    areAllTestsPassing,
    setInspectedTest,
    setResults,
    setTestBeingEdited,
    handleDeleteTest,
    handleUpdateTest,
    handleCancelEditing,
    handleAddNewTest,
  }
}
