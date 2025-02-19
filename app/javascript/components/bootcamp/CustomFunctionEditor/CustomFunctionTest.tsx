import React, { useState, useCallback } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function CustomFunctionTest({
  params,
  expected,
  editMode,
  fnName,
  passing,
  actual,
  isInspected,
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
  isInspected: boolean
  fnName: string
  actual: any
  onEditClick: () => void
  onTestClick: () => void
  onSaveClick: (paramsValue: string, expectedValue: string) => void
  onCancelClick: () => void
  onDeleteClick: () => void
}) {
  const [paramsValue, setParamsValue] = useState(params)
  const [expectedValue, setExpectedValue] = useState(expected)

  const handleSaveTest = useCallback(() => {
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
        'c-scenario',
        !actual
          ? 'pending bg-blue-300'
          : passing
          ? 'pass bg-green-300'
          : 'fail bg-red-300',
        isInspected && 'outline-dashed'
      )}
    >
      <table className="io-test-result-info">
        <tbody>
          <tr>
            <th>Code run:</th>
            <td>
              {fnName}(
              {editMode ? (
                <input
                  type="text"
                  value={paramsValue}
                  onChange={(e) => setParamsValue(e.target.value)}
                />
              ) : (
                params
              )}
              )
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
              <td>{actual}</td>
            </tr>
          )}
        </tbody>
      </table>
      {editMode ? (
        <button onClick={handleCancelEditing}>cancel</button>
      ) : (
        <button onClick={onEditClick}>edit</button>
      )}
      <button onClick={handleSaveTest}>save</button>
      <button onClick={onDeleteClick}>delete</button>
    </div>
  )
}
