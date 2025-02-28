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
    <div onClick={onTestClick}>
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
          hasResult={hasResult}
          passing={passing}
          onEditClick={onEditClick}
          onDeleteClick={onDeleteClick}
          handleSaveTest={handleSaveTest}
          handleCancelEditing={handleCancelEditing}
        />
      ) : (
        <CollapsedView
          hasResult={hasResult}
          testTitle={testTitle}
          passing={passing}
        />
      )}
    </div>
  )
}

function CollapsedView({
  testTitle,
  passing,
  hasResult,
}: {
  testTitle: string
  passing: boolean
  hasResult: boolean
}) {
  const className = assembleClassNames(
    'collapsed',
    !hasResult ? 'pending' : passing ? 'pass' : 'fail'
  )
  return (
    <div className={className}>
      <h3 className="font-semibold text-16">{testTitle}</h3>
      {/* {!hasResult ? 'No result yet' : passing ? 'Passing' : 'Failing'} */}
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
  hasResult,
  passing,
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
  hasResult: boolean
  passing: boolean
  onEditClick: () => void
  onDeleteClick: () => void
  handleSaveTest: () => void
  handleCancelEditing: () => void
}) {
  const className = assembleClassNames(
    'c-scenario',
    !hasResult ? 'pending' : passing ? 'pass' : 'fail'
  )
  return (
    <>
      <div className={className}>
        <div className="scenario-lhs">
          <div className="scenario-lhs-conten">
            <div className="header">
              <h3 className="font-semibold text-16 mr-auto">{testTitle}</h3>
              <div className="flex items-center gap-8">
                {editMode ? (
                  <></>
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

            <table
              className={`io-test-result-info ${editMode ? 'edit-mode' : ''}`}
            >
              <tbody>
                <tr>
                  <th>Code run:</th>
                  <td className="editable">
                    <div className={editMode ? 'c-faux-input' : ''}>
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
                  <td className="editable">
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
          </div>
        </div>
      </div>

      {editMode && (
        <div className="flex gap-8 mt-8">
          <button
            onClick={(e) => {
              e.stopPropagation()
              handleSaveTest()
            }}
            className="btn btn-primary flex-grow"
          >
            save
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation()
              handleCancelEditing()
            }}
            className="btn btn-secondary w-1-3"
          >
            cancel
          </button>
        </div>
      )}
    </>
  )
}

function formatActual(actual: string | null | undefined) {
  if (actual === null || actual === undefined) {
    return "[Your function didn't return anything]"
  }

  return actual
}
