import React, { useState, useCallback } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import toast from 'react-hot-toast'
import { GraphicalIcon } from '@/components/common'
import { useHighlighting } from '@/hooks/use-syntax-highlighting'

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
  readonly,
  syntaxError,
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
  readonly: boolean | undefined
  syntaxError: string | null
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
          readonly={readonly}
          syntaxError={syntaxError}
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
          readonly={readonly}
          syntaxError={syntaxError}
        />
      )}
    </div>
  )
}

function CollapsedView({
  testTitle,
  passing,
  hasResult,
  readonly,
  syntaxError,
}: {
  testTitle: string
  passing: boolean
  hasResult: boolean
  readonly: boolean | undefined
  syntaxError: string | null
}) {
  const className = assembleClassNames(
    'collapsed',
    getTestStatus(syntaxError, hasResult, passing)
  )
  return (
    <div
      className={assembleClassNames(
        className,
        readonly && 'flex items-center justify-between'
      )}
    >
      <h3 className="font-semibold text-16">{testTitle}</h3>
      {readonly && (
        <GraphicalIcon
          icon="readonly-lock"
          category="bootcamp"
          width={20}
          height={20}
          className=" opacity-[0.6]"
        />
      )}

      {/* {!hasResult ? 'No result yet' : passing ? 'Passing' : 'Failing'} */}
    </div>
  )
}

function ExpandedView({
  args,
  argsValue,
  setArgsValue,
  expected,
  expectedValue,
  setExpectedValue,
  editMode,
  name,
  actual,
  testTitle,
  hasResult,
  passing,
  readonly,
  syntaxError,
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
  readonly: boolean | undefined
  syntaxError: string | null
  onEditClick: () => void
  onDeleteClick: () => void
  handleSaveTest: () => void
  handleCancelEditing: () => void
}) {
  const className = assembleClassNames(
    'c-scenario',
    getTestStatus(syntaxError, hasResult, passing)
  )
  return (
    <>
      <div className={className}>
        <div className="scenario-lhs">
          <div className="scenario-lhs-conten">
            <div className="header">
              <h3 className="font-semibold text-16 mr-auto">{testTitle}</h3>
              <div className="flex items-center gap-8">
                <TestTopRHS
                  editMode={editMode}
                  onDeleteClick={onDeleteClick}
                  onEditClick={onEditClick}
                  readonly={readonly}
                />
              </div>
            </div>
            <SyntaxError syntaxError={syntaxError} />

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
                  <td className="editable whitespace-pre">
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
                    <td className="whitespace-pre">{formatActual(actual)}</td>
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

function TestTopRHS({
  editMode,
  onEditClick,
  onDeleteClick,
  readonly,
}: {
  editMode: boolean
  readonly: boolean | undefined
  onEditClick: () => void
  onDeleteClick: () => void
}) {
  if (readonly) {
    return (
      <GraphicalIcon
        icon="readonly-lock"
        category="bootcamp"
        width={20}
        height={20}
        className="opacity-[0.6]"
      />
    )
  }

  if (editMode) return null

  return (
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
  )
}

function SyntaxError({ syntaxError }: { syntaxError: string | null }) {
  const ref = useHighlighting<HTMLDivElement>(syntaxError || '')

  if (!syntaxError) {
    return null
  }

  return (
    <div
      ref={ref}
      className="p-12 text-bootcamp-fail-dark text-16 border-b-1 border-bootcamp-fail-dark"
      dangerouslySetInnerHTML={{ __html: syntaxError }}
    />
  )
}

function getTestStatus(
  syntaxError: string | null,
  hasResult: boolean,
  passing: boolean
): 'fail' | 'pending' | 'pass' {
  if (syntaxError) return 'fail'
  if (!hasResult) return 'pending'
  return passing ? 'pass' : 'fail'
}
