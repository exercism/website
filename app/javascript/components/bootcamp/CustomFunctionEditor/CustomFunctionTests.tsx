import React from 'react'
import { CustomFunctionTest } from './CustomFunctionTest'
import { CustomTests, Results } from './useTestManager'

export function CustomFunctionTests({
  tests,
  fnName,
  testBeingEdited,
  results,
  inspectedTest,
  setTestBeingEdited,
  setInspectedTest,
  handleDeleteTest,
  handleUpdateTest,
  handleCancelEditing,
  handleAddNewTest,
}: {
  tests: CustomTests
  fnName: string
  testBeingEdited: string | undefined
  inspectedTest: string
  results: Results
  setTestBeingEdited: React.Dispatch<React.SetStateAction<string | undefined>>
  setInspectedTest: React.Dispatch<React.SetStateAction<string>>
  handleDeleteTest: (uuid: string) => void
  handleUpdateTest: (
    uuid: string,
    newCodeRun: string,
    newExpected: string
  ) => void
  handleCancelEditing: () => void
  handleAddNewTest: () => void
}) {
  return (
    <div className="flex flex-col gap-8">
      {tests?.map((test) => {
        return (
          <CustomFunctionTest
            key={test.uuid}
            params={test.params}
            passing={
              results && results[test.uuid] ? results[test.uuid].pass : false
            }
            fnName={fnName}
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
      <button onClick={handleAddNewTest} className="btn btn-primary">
        Add new test
      </button>
    </div>
  )
}
