import { create } from 'zustand'
import { v4 as uuid } from 'uuid'
import { Frame } from '@/interpreter/frames'
import { EditorView } from 'codemirror'
import { CustomFunction } from '../CustomFunctionEditor'
import toast from 'react-hot-toast'
import { AnimationTimeline } from '../../JikiscriptExercisePage/AnimationTimeline/AnimationTimeline'
import { updateUnfoldableFunctions } from '../../JikiscriptExercisePage/CodeMirror/unfoldableFunctionNames'

export type CustomTests = {
  args: string
  expected: string
  uuid: string
  readonly?: boolean
}[]
export type Results = Record<
  string,
  {
    actual: any
    frames: Frame[]
    pass: boolean
    animationTimeline: AnimationTimeline
  }
>
export type CustomFunctionEditorStoreState = {
  initializeStore: (customFunction: CustomFunction) => void
  tests: CustomTests
  syntaxErrorInTest: { message: string; testUuid: string } | null
  setSyntaxErrorInTest: (syntaxErrorInTest: {
    message: string
    testUuid: string
  }) => void
  clearSyntaxErrorInTest: () => void
  inspectedTest: string
  clearInspectedTest: () => void
  setInspectedTest: (uuid: string) => void
  inspectedFrames: Frame[]
  testBeingEdited: string | undefined
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
  clearResults: () => void
  areAllTestsPassing: boolean
  customFunctionName: string
  isPredefined: boolean
  setCustomFunctionName: (customFunctionName: string) => void
  customFunctionDescription: string
  setCustomFunctionDescription: (customFunctionDescription: string) => void
  isActivated: boolean
  setIsActivated: (isActivated: boolean) => void
  hasUnsavedChanges: boolean
  setHasUnsavedChanges: (hasUnsavedChanges: boolean) => void
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
  typeof customFunctionEditorStore
>

const customFunctionEditorStore = create<CustomFunctionEditorStoreState>(
  (set, get) => ({
    initializeStore: (customFunction) => {
      set({
        customFunctionName: customFunction.name,
        isPredefined: customFunction.predefined,
        isActivated: customFunction.active,
        customFunctionDescription: customFunction.description,
        tests: customFunction.tests,
        testBeingEdited: undefined,
      })
    },
    customFunctionName: '',
    syntaxErrorInTest: null,
    setSyntaxErrorInTest: (syntaxErrorInTest) => {
      set({
        syntaxErrorInTest,
        inspectedTest: syntaxErrorInTest.testUuid,
        isActivated: false,
      })
    },
    clearSyntaxErrorInTest: () => {
      set({ syntaxErrorInTest: null })
    },
    isPredefined: false,
    setCustomFunctionName: (customFunctionName) => {
      set({
        customFunctionName,
        hasUnsavedChanges: true,
      })
    },
    customFunctionArity: 0,
    setCustomFunctionArity: (customFunctionArity) => {
      set({ customFunctionArity, hasUnsavedChanges: true })
    },
    handleSetCustomFunctionName: (view: EditorView) => {
      const docText = view.state.doc.toString()
      const functionName = extractFunctionName(docText) ?? ''
      updateUnfoldableFunctions(view, [functionName])

      set({
        customFunctionName: functionName,
        hasUnsavedChanges: true,
      })
    },

    customFunctionDescription: '',
    setCustomFunctionDescription: (customFunctionDescription) => {
      set({ customFunctionDescription, hasUnsavedChanges: true })
    },
    isActivated: false,
    setIsActivated: (isActivated) => {
      set({ isActivated, hasUnsavedChanges: true })
    },
    hasUnsavedChanges: false,
    setHasUnsavedChanges: (hasUnsavedChanges) => {
      set({ hasUnsavedChanges })
    },
    toggleIsActivated: () => {
      set((state) => {
        return {
          isActivated: !state.isActivated,
          hasUnsavedChanges: true,
        }
      })
    },
    tests: [],
    inspectedTest: '',
    clearInspectedTest: () => {
      set(() => {
        return { inspectedTest: '', inspectedFrames: [] }
      })
    },
    setInspectedTest: (uuid: string) => {
      const { testBeingEdited, inspectedTest } = get()
      if (inspectedTest === uuid) {
        return
      }

      if (testBeingEdited) {
        toast(
          'You are editing a test. Save that first before inspecting a test result.'
        )

        return
      }

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
      const { testBeingEdited, tests } = get()

      if (testBeingEdited) {
        if (!tests[testBeingEdited]) {
          toast(
            'You already have an unsaved empty test. Finish that first, then you can add a new test.'
          )

          return
        }
      }

      const newUuid = uuid()
      set((state) => {
        const newTests = [
          ...state.tests,
          {
            args: '',
            expected: '',
            uuid: newUuid,
          },
        ]

        return {
          tests: newTests,
          inspectedTest: newUuid,
          testBeingEdited: newUuid,
          hasUnsavedChanges: true,
        }
      })
    },
    handleDeleteTest: (uuid: string) => {
      if (window.confirm('Are you sure you want to delete this test?')) {
        set((state) => {
          const newTests = state.tests.filter((t) => t.uuid !== uuid)
          return {
            tests: newTests,
            hasUnsavedChanges: true,
          }
        })
      }
    },
    handleUpdateTest: (
      uuid: string,
      newParams: string,
      newExpected: string
    ) => {
      set((state) => {
        const newTests = state.tests.map((test) =>
          test.uuid === uuid
            ? { ...test, args: newParams, expected: newExpected }
            : test
        )
        return {
          testBeingEdited: undefined,
          tests: newTests,
          hasUnsavedChanges: true,
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
      const isActivated = areAllTestsPassing
      set({
        results,
        areAllTestsPassing,
        isActivated,
        hasUnsavedChanges: true,
      })
    },
    clearResults: () => {
      set({ results: {}, areAllTestsPassing: false, isActivated: false })
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
        name: state.customFunctionName,
        active: state.isActivated && state.areAllTestsPassing,
        code,
        description: state.customFunctionDescription,
        arity: state.customFunctionArity,
        tests: state.tests,
        dependsOn,
      })

      set({ hasUnsavedChanges: false })
    },
  })
)

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
  arity,
  dependsOn,
}: {
  url: string
  name: string
  active: boolean
  description: string
  code: string
  tests: CustomTests
  arity: number
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
        arity,
        depends_on: dependsOn,
      },
    }),
  })

  if (!response.ok) {
    toast.error('Failed to save changes')
    throw new Error('Failed to submit code')
  }

  toast.success('Saved changes successfully!')

  return response.json()
}

export default customFunctionEditorStore
