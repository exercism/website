import React, { useState, useCallback } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import toast from 'react-hot-toast'

export function CustomFunctionTest({
  params,
  expected,
  editMode,
  name,
  fnName,
  passing,
  hasResult,
  actual,
  isInspected,
  testTitle,
  onTestClick,
  onEditClick,
  onSaveClick,
  onCancelClick,
  onDeleteClick,
}: {
  params: string
  expected: string
  editMode: boolean
  passing: boolean
  hasResult: boolean
  isInspected: boolean
  name: string
  fnName: string
  actual: any
  testTitle: string
  onEditClick: () => void
  onTestClick: () => void
  onSaveClick: (paramsValue: string, expectedValue: string) => void
  onCancelClick: () => void
  onDeleteClick: () => void
}) {
  const [paramsValue, setParamsValue] = useState(params)
  const [expectedValue, setExpectedValue] = useState(expected)

  const handleSaveTest = useCallback(() => {
    if (expectedValue.length === 0) {
      toast.error('You need to provide an expected value before saving')
      return
    }
    onSaveClick(paramsValue, expectedValue)
  }, [onSaveClick, paramsValue, expectedValue])

  const handleCancelEditing = useCallback(() => {
    if ([params, expected].every((v) => v.length === 0)) {
      onDeleteClick()
    }
    onCancelClick()
    setParamsValue(params)
    setExpectedValue(expected)
  }, [params, expected])

  return (
    <div
      onClick={onTestClick}
      className={assembleClassNames(
        'c-scenario flex flex-col',
        !hasResult
          ? 'pending bg-blue-300'
          : passing
          ? 'pass bg-green-300'
          : 'fail bg-red-300',
        isInspected && 'outline-dashed'
      )}
    >
      {isInspected ? (
        <ExpandedView
          params={params}
          paramsValue={paramsValue}
          setParamsValue={setParamsValue}
          expected={expected}
          expectedValue={expectedValue}
          setExpectedValue={setExpectedValue}
          editMode={editMode}
          fnName={fnName}
          actual={actual}
          testTitle={testTitle}
          onEditClick={onEditClick}
          onDeleteClick={onDeleteClick}
          handleSaveTest={handleSaveTest}
          handleCancelEditing={handleCancelEditing}
        />
      ) : (
        <CollapsedView
          resultsIsMissing={!hasResult}
          testTitle={testTitle}
          isPassing={passing}
        />
      )}
    </div>
  )
}

function CollapsedView({
  testTitle,
  isPassing,
  resultsIsMissing,
}: {
  testTitle: string
  isPassing: boolean
  resultsIsMissing: boolean
}) {
  return (
    <div>
      {testTitle} -{' '}
      {resultsIsMissing ? 'No result yet' : isPassing ? 'Passing' : 'Failing'}
    </div>
  )
}

function ExpandedView({
  params,
  paramsValue,
  setParamsValue,
  expected,
  expectedValue,
  setExpectedValue,
  editMode,
  fnName,
  actual,
  testTitle,
  onEditClick,
  onDeleteClick,
  handleSaveTest,
  handleCancelEditing,
}: {
  params: string
  paramsValue: string
  setParamsValue: React.Dispatch<React.SetStateAction<string>>
  expectedValue: string
  setExpectedValue: React.Dispatch<React.SetStateAction<string>>
  expected: string
  editMode: boolean
  fnName: string
  actual: any
  testTitle: string
  onEditClick: () => void
  onDeleteClick: () => void
  handleSaveTest: () => void
  handleCancelEditing: () => void
}) {
  return (
    <>
      <div className="flex items-center justify-between">
        <h3 className="font-semibold text-18">{testTitle}</h3>
        <div className="flex items-center gap-8">
          {editMode ? (
            <>
              <button
                onClick={(e) => {
                  e.stopPropagation()
                  handleSaveTest()
                }}
              >
                save
              </button>
              <button
                onClick={(e) => {
                  e.stopPropagation()
                  handleCancelEditing()
                }}
              >
                cancel
              </button>
            </>
          ) : (
            <>
              <button
                onClick={(e) => {
                  e.stopPropagation()
                  onEditClick()
                }}
              >
                edit
              </button>
              <button
                onClick={(e) => {
                  e.stopPropagation()
                  onDeleteClick()
                }}
              >
                delete
              </button>
            </>
          )}
        </div>
      </div>
      <table className="io-test-result-info">
        <tbody>
          <tr>
            <th>Code run:</th>
            <td>
              <div className="c-faux-input">
                {fnName}(
                {editMode ? (
                  <input
                    type="text"
                    value={paramsValue}
                    className="!px-6 !flex-grow-0"
                    onChange={(e) => setParamsValue(e.target.value)}
                  />
                ) : (
                  params
                )}
                )
              </div>
            </td>
          </tr>
          <tr>
            <th>Expected:</th>
            <td>
              {editMode ? (
                <input
                  type="text"
                  value={expectedValue}
                  onChange={(e) => setExpectedValue(e.target.value)}
                />
              ) : (
                expected
              )}
            </td>
          </tr>
          {actual && (
            <tr>
              <th>Actual:</th>
              <td>{formatActual(actual)}</td>
            </tr>
          )}
        </tbody>
      </table>
    </>
  )
}

function formatActual(actual: string | null | undefined) {
  if (actual === null || actual === undefined) {
    return "[Your function didn't return anything]"
  }

  return actual
}
