import { useState, useCallback, useEffect } from 'react'
import { v4 as uuid } from 'uuid'
import { CustomFunction } from './CustomFunctionEditor'
import { useLocalStorage } from '@uidotdev/usehooks'

export type CustomTests = { codeRun: string; expected: string; uuid: string }[]

export function useTestManager(customFunction: CustomFunction) {
  const [testsLocalStorageValue, setTestsLocalStorageValue] = useLocalStorage(
    `custom-fn-tests-${customFunction.uuid}`,
    { tests: customFunction.tests }
  )
  const [tests, setTests] = useState<CustomTests>(
    testsLocalStorageValue.tests ?? []
  )

  useEffect(() => {
    setTestsLocalStorageValue({ tests })
  }, [tests])

  const [testBeingEdited, setTestBeingEdited] = useState<string>()

  const handleAddNewTest = useCallback(() => {
    const newUuid = uuid()
    setTests((tests) => [
      ...tests,
      {
        codeRun: '',
        expected: '',
        uuid: newUuid,
      },
    ])

    setTestBeingEdited(newUuid)
  }, [])

  const handleDeleteTest = useCallback((uuid: string) => {
    setTests((tests) => tests.filter((t) => t.uuid !== uuid))
  }, [])

  const handleUpdateTest = useCallback(
    (uuid: string, newCodeRun: string, newExpected: string) => {
      setTests((tests) =>
        tests.map((test) =>
          test.uuid === uuid
            ? { ...test, codeRun: newCodeRun, expected: newExpected }
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
    setTestBeingEdited,
    handleDeleteTest,
    handleUpdateTest,
    handleCancelEditing,
    handleAddNewTest,
  }
}
