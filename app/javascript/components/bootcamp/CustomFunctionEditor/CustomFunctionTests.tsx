import React, { useContext } from 'react'
import { CustomFunctionTest } from './CustomFunctionTest'
import { CustomFunctionEditorStoreContext } from './CustomFunctionEditor'

export function CustomFunctionTests() {
  const { customFunctionEditorStore } = useContext(
    CustomFunctionEditorStoreContext
  )

  const {
    customFunctionDisplayName,
    results,
    tests,
    testBeingEdited,
    inspectedTest,
    setTestBeingEdited,
    setInspectedTest,
    handleDeleteTest,
    handleUpdateTest,
    handleCancelEditing,
    handleAddNewTest,
  } = customFunctionEditorStore()

  return (
    <div className="flex flex-col gap-8 max-h-[50%] overflow-auto">
      {tests?.map((test, idx) => {
        return (
          <CustomFunctionTest
            testTitle={`Test ${idx + 1}`}
            key={test.uuid}
            params={test.params}
            passing={
              results && results[test.uuid] ? results[test.uuid].pass : false
            }
            fnName={customFunctionDisplayName}
            isInspected={inspectedTest === test.uuid}
            onTestClick={() => setInspectedTest(test.uuid)}
            actual={
              results && results[test.uuid] ? results[test.uuid].actual : null
            }
            expected={test.expected}
            editMode={testBeingEdited === test.uuid}
            onEditClick={() => setTestBeingEdited(test.uuid)}
            onDeleteClick={() => handleDeleteTest(test.uuid)}
            onSaveClick={(newParams: string, newExpected: string) =>
              handleUpdateTest(test.uuid, newParams, newExpected)
            }
            onCancelClick={handleCancelEditing}
          />
        )
      })}
      <button onClick={handleAddNewTest} className="btn btn-primary shrink-0">
        Add new test
      </button>
    </div>
  )
}
