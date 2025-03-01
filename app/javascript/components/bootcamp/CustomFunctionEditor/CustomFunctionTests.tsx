import React, { useContext } from 'react'
import { CustomFunctionTest } from './CustomFunctionTest'
import { CustomFunctionEditorStoreContext } from './CustomFunctionEditor'

export function CustomFunctionTests() {
  const { customFunctionEditorStore } = useContext(
    CustomFunctionEditorStoreContext
  )

  const {
    customFunctionName,
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
    <div className="flex flex-col gap-8">
      {tests?.map((test, idx) => {
        return (
          <CustomFunctionTest
            testTitle={`Test ${idx + 1}`}
            key={test.uuid}
            args={test.args}
            passing={
              results && results[test.uuid] ? results[test.uuid].pass : false
            }
            hasResult={!!results[test.uuid]}
            name={customFunctionName}
            isInspected={inspectedTest === test.uuid}
            onTestClick={() => setInspectedTest(test.uuid)}
            actual={
              results && results[test.uuid] ? results[test.uuid].actual : null
            }
            expected={test.expected}
            editMode={testBeingEdited === test.uuid}
            onEditClick={() => setTestBeingEdited(test.uuid)}
            onDeleteClick={() => handleDeleteTest(test.uuid)}
            onSaveClick={(newArgs: string, newExpected: string) =>
              handleUpdateTest(test.uuid, newArgs, newExpected)
            }
            onCancelClick={handleCancelEditing}
          />
        )
      })}
      {!testBeingEdited && (
        <button onClick={handleAddNewTest} className="btn btn-primary shrink-0">
          Add new test
        </button>
      )}
    </div>
  )
}
