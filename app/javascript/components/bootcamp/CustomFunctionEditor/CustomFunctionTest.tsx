import React, { useState, useCallback } from 'react'

export function CustomFunctionTest({
  codeRun,
  expected,
  editMode,
  onEditClick,
  onSaveClick,
  onCancelClick,
  onDeleteClick,
}: {
  codeRun: string
  expected: string
  editMode: boolean
  onEditClick: () => void
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
    <div className="c-scenario pending bg-blue-300">
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
