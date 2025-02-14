import { useState, useCallback } from 'react'
import { v4 as uuid } from 'uuid'

export type CustomTests = { codeRun: string; expected: string; uuid: string }[]

export function useTestManager() {
  const [tests, setTests] = useState<CustomTests>([])

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
