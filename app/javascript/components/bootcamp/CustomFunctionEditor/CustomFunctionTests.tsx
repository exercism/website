import React from 'react'
import { CustomFunctionTest } from './CustomFunctionTest'
import { CustomTest } from './useTestManager'

export function CustomFunctionTests({
  tests,
  testBeingEdited,
  setTestBeingEdited,
  handleDeleteTest,
  handleUpdateTest,
  handleCancelEditing,
  handleAddNewTest,
}: {
  tests: CustomTest
  testBeingEdited: string | undefined
  setTestBeingEdited: React.Dispatch<React.SetStateAction<string | undefined>>
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
            codeRun={test.codeRun}
            expected={test.expected}
            editMode={testBeingEdited === test.uuid}
            onEditClick={() => setTestBeingEdited(test.uuid)}
            onDeleteClick={() => handleDeleteTest(test.uuid)}
            onSaveClick={(newCodeRun: string, newExpected: string) =>
              handleUpdateTest(test.uuid, newCodeRun, newExpected)
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
