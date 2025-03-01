import React, { useState, useCallback } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import toast from 'react-hot-toast'

export function CustomFunctionTest({
  args,
  expected,
  editMode,
  name,
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
  args: string
  expected: string
  editMode: boolean
  passing: boolean
  hasResult: boolean
  isInspected: boolean
  name: string
  actual: any
  testTitle: string
  onEditClick: () => void
  onTestClick: () => void
  onSaveClick: (argsValue: string, expectedValue: string) => void
  onCancelClick: () => void
  onDeleteClick: () => void
}) {
  const [argsValue, setArgsValue] = useState(args)
  const [expectedValue, setExpectedValue] = useState(expected)

  const handleSaveTest = useCallback(() => {
    if (expectedValue.length === 0) {
      toast.error('You need to provide an expected value before saving')
      return
    }
    onSaveClick(argsValue, expectedValue)
  }, [onSaveClick, argsValue, expectedValue])

  const handleCancelEditing = useCallback(() => {
    if ([args, expected].every((v) => v.length === 0)) {
      onDeleteClick()
    }
    onCancelClick()
    setArgsValue(args)
    setExpectedValue(expected)
  }, [args, expected])

  return (
    <div onClick={onTestClick}>
      {isInspected ? (
        <ExpandedView
          args={args}
          argsValue={argsValue}
          setArgsValue={setArgsValue}
          expected={expected}
          expectedValue={expectedValue}
          setExpectedValue={setExpectedValue}
          editMode={editMode}
          name={name}
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
  args: args,
  argsValue: argsValue,
  setArgsValue: setArgsValue,
  expected,
  expectedValue,
  setExpectedValue,
  editMode,
  name,
  actual,
  testTitle,
  hasResult,
  passing,
  onEditClick,
  onDeleteClick,
  handleSaveTest,
  handleCancelEditing,
}: {
  args: string
  argsValue: string
  setArgsValue: React.Dispatch<React.SetStateAction<string>>
  expectedValue: string
  setExpectedValue: React.Dispatch<React.SetStateAction<string>>
  expected: string
  editMode: boolean
  name: string
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
                      {name}(
                      {editMode ? (
                        <input
                          type="text"
                          value={argsValue}
                          className="!px-6 !flex-grow-0"
                          onChange={(e) => setArgsValue(e.target.value)}
                        />
                      ) : (
                        args
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
  if (actual === 'null') {
    return "[Your function didn't return anything]"
  }

  return actual
}
