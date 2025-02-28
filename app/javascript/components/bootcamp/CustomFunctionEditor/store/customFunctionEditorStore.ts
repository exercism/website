import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { v4 as uuid } from 'uuid'
import { Frame } from '@/interpreter/frames'
import { EditorView } from 'codemirror'
import { CustomFunction } from '../CustomFunctionEditor'

export type CustomTests = { params: string; expected: string; uuid: string }[]
export type Results = Record<
  string,
  { actual: any; frames: Frame[]; pass: boolean }
>
export type CustomFunctionEditorStoreState = {
  initializeStore: (customFunction: CustomFunction) => void
  tests: CustomTests
  inspectedTest: string
  setInspectedTest: (uuid: string) => void
  inspectedFrames: Frame[]
  testBeingEdited: string
  setTestBeingEdited: (testBeingEdited: string) => void
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
  customFunctionName: string
  customFunctionDisplayName: string
  setCustomFunctionName: (customFunctionName: string) => void
  customFunctionDescription: string
  setCustomFunctionDescription: (customFunctionDescription: string) => void
  isActivated: boolean
  setIsActivated: (isActivated: boolean) => void
  toggleIsActivated: () => void
  handleSetCustomFunctionName: (view: EditorView) => void
  customFunctionArity: number
  setCustomFunctionArity: (customFunctionArity: number) => void
  handlePatchCustomFunction: ({
    url,
    dependsOn,
    code,
  }: {
    url: string
    dependsOn: string[]
    code: string
  }) => void
}

export type CustomFunctionEditorStore = ReturnType<
  typeof createCustomFunctionEditorStore
>

export function createCustomFunctionEditorStore(customFnUuid: string) {
  return create<CustomFunctionEditorStoreState>()(
    persist(
      (set, get) => ({
        initializeStore: (customFunction) => {
          set({
            customFunctionName: customFunction.fnName,
            customFunctionDisplayName: customFunction.name,
            isActivated: customFunction.active,
            customFunctionDescription: customFunction.description,
            tests: customFunction.tests,
          })
        },
        customFunctionName: '',
        customFunctionDisplayName: '',
        setCustomFunctionName: (customFunctionName) => {
          const displayName = customFunctionName.replace('my#', '')
          set({
            customFunctionName,
            customFunctionDisplayName: displayName,
          })
        },
        customFunctionArity: 0,
        setCustomFunctionArity: (customFunctionArity) => {
          set({ customFunctionArity })
        },
        handleSetCustomFunctionName: (view: EditorView) => {
          const docText = view.state.doc.toString()
          const functionName = extractFunctionName(docText) ?? ''

          const displayName = functionName.replace('my#', '')

          set({
            customFunctionName: functionName,
            customFunctionDisplayName: displayName,
          })
        },

        customFunctionDescription: '',
        setCustomFunctionDescription: (customFunctionDescription) => {
          set({ customFunctionDescription })
        },
        isActivated: false,
        setIsActivated: (isActivated) => {
          set({ isActivated })
        },
        toggleIsActivated: () => {
          set((state) => {
            return {
              isActivated: !state.isActivated,
            }
          })
        },
        tests: [],
        inspectedTest: '',
        setInspectedTest: (uuid: string) => {
          set((state) => {
            const results = state.results
            const inspectedFrames = results[uuid] ? results[uuid].frames : []
            return { inspectedTest: uuid, inspectedFrames }
          })
        },
        inspectedFrames: [],
        testBeingEdited: '',
        setTestBeingEdited: (testBeingEdited) => {
          set({ testBeingEdited })
        },
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
          console.log('results', results)
          const areAllTestsPassing = Object.values(results).every(
            (result) => result.pass
          )
          set({ results, areAllTestsPassing })
        },
        areAllTestsPassing: false,

        handlePatchCustomFunction: ({
          url,
          dependsOn,
          code,
        }: {
          url: string
          dependsOn: string[]
          code: string
        }) => {
          const state = get()

          patchCustomFunction({
            url,
            name: state.customFunctionName.replace('my#', ''),
            fn_name: state.customFunctionName,
            active: state.isActivated && state.areAllTestsPassing,
            code,
            description: state.customFunctionDescription,
            fn_arity: state.customFunctionArity,
            tests: state.tests,
            dependsOn,
          })
        },
      }),
      {
        name: `custom-function-editor-store-${customFnUuid}`,
      }
    )
  )
}

function extractFunctionName(code: string): string | null {
  const match = code.match(/function\s+(my#[a-zA-Z_$][a-zA-Z0-9_$]*)/)
  return match ? match[1] : null
}

export async function patchCustomFunction({
  url,
  name,
  active,
  description,
  code,
  tests,
  fn_name,
  fn_arity,
  dependsOn,
}: {
  url: string
  name: string
  active: boolean
  description: string
  code: string
  tests: CustomTests
  fn_name: string
  fn_arity: number
  dependsOn: string[]
}) {
  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      custom_function: {
        name,
        active,
        description,
        code,
        tests,
        fn_name,
        fn_arity,
        depends_on: dependsOn,
      },
    }),
  })

  if (!response.ok) {
    throw new Error('Failed to submit code')
  }

  return response.json()
}
