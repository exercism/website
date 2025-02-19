import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useState, useCallback } from 'react'

export function CustomFunctionTest({
  codeRun,
  expected,
  editMode,
  actual,
  isInspected,
  onTestClick,
  onEditClick,
  onSaveClick,
  onCancelClick,
  onDeleteClick,
}: {
  codeRun: string
  expected: string
  editMode: boolean
  isInspected: boolean
  actual: any
  onEditClick: () => void
  onTestClick: () => void
  onSaveClick: (codeRunValue: string, expectedValue: string) => void
  onCancelClick: () => void
  onDeleteClick: () => void
}) {
  const [codeRunValue, setCodeRunValue] = useState(codeRun)
  const [expectedValue, setExpectedValue] = useState(expected)

  const handleSaveTest = useCallback(() => {
    onSaveClick(codeRunValue, expectedValue)
  }, [onSaveClick, codeRunValue, expectedValue])

  const handleCancelEditing = useCallback(() => {
    if ([codeRun, expected].every((v) => v.length === 0)) {
      onDeleteClick()
    }
    onCancelClick()
    setCodeRunValue(codeRun)
    setExpectedValue(expected)
  }, [codeRun, expected])

  return (
    <div
      onClick={onTestClick}
      className={assembleClassNames(
        'c-scenario',
        !actual
          ? 'pending bg-blue-300'
          : actual === expected
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
              {editMode ? (
                <input
                  type="text"
                  value={codeRunValue}
                  onChange={(e) => setCodeRunValue(e.target.value)}
                />
              ) : (
                codeRun
              )}{' '}
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
