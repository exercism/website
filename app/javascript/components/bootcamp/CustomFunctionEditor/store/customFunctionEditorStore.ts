import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { v4 as uuid } from 'uuid'
import { Frame } from '@/interpreter/frames'

export type CustomTests = { params: string; expected: string; uuid: string }[]
export type Results = Record<
  string,
  { actual: any; frames: Frame[]; pass: boolean }
>
type StoreState = {
  tests: CustomTests
  inspectedTest: string
  testBeingEdited: string
  handleAddNewTest: () => void
  handleDeleteTest: (uuid: string) => void
  handleUpdateTest: (
    uuid: string,
    newParams: string,
    newExpected: string
  ) => void
  handleCancelEditing: () => void
  results: Results
  setResults: (results: Results) => void
  areAllTestsPassing: boolean
}

export function createCustomFunctionEditorStore(customFnUuid: string) {
  return create<StoreState>()(
    persist(
      (set) => ({
        tests: [],
        inspectedTest: '',
        testBeingEdited: '',
        handleAddNewTest: () => {
          const newUuid = uuid()
          set((state) => {
            const newTests = [
              ...state.tests,
              {
                params: '',
                expected: '',
                uuid: newUuid,
              },
            ]

            return {
              tests: newTests,
              inspectedTest: newUuid,
              testBeingEdited: newUuid,
            }
          })
        },
        handleDeleteTest: (uuid: string) => {
          set((state) => {
            const newTests = state.tests.filter((t) => t.uuid !== uuid)
            return {
              tests: newTests,
            }
          })
        },
        handleUpdateTest: (
          uuid: string,
          newParams: string,
          newExpected: string
        ) => {
          set((state) => {
            const newTests = state.tests.map((test) =>
              test.uuid === uuid
                ? { ...test, params: newParams, expected: newExpected }
                : test
            )
            return {
              testBeingEdited: undefined,
              tests: newTests,
            }
          })
        },
        handleCancelEditing: () => {
          set({ testBeingEdited: undefined })
        },

        results: {},
        setResults: (results: Results) => {
          const areAllTestsPassing = Object.values(results).every(
            (result) => result.pass
          )
          set({ results, areAllTestsPassing })
        },
        areAllTestsPassing: false,
      }),
      {
        name: `custom-function-editor-store-${customFnUuid}`,
      }
    )
  )
}
