import React, { useMemo } from 'react'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import customFunctionEditorStore from './store/customFunctionEditorStore'

const labelClassName = 'text-16 font-semibold mb-8'
export function CustomFunctionDetails() {
  const {
    customFunctionName,
    isPredefined,
    customFunctionDescription,
    setCustomFunctionDescription,
  } = customFunctionEditorStore()

  const functionNameEmpty = useMemo(
    () => customFunctionName.length === 0,
    [customFunctionName]
  )

  return (
    <div className="flex flex-col">
      <label className={labelClassName} htmlFor="fn-name">
        Function name
        {functionNameEmpty && (
          <span className="text-bootcamp-fail-dark ml-4 inline-block">
            - cannot be empty
          </span>
        )}
      </label>
      <div className="relative">
        <input
          className={`mb-16 !bg-[#eee] w-fill ${
            functionNameEmpty
              ? '!border-bootcamp-fail-dark !bg-bootcamp-fail-light'
              : ''
          }`}
          name="fn-name"
          type="text"
          readOnly
          value={customFunctionName}
        />
        <GraphicalIcon
          icon="readonly-lock"
          category="bootcamp"
          className="absolute right-[12px] top-[15px] opacity-[0.6]"
          width={20}
          height={20}
        />
      </div>

      <label className={labelClassName} htmlFor="description">
        Description
      </label>
      <div className="relative">
        <textarea
          name="description"
          className={assembleClassNames(
            'mb-16 w-fill',
            isPredefined && '!bg-[#eee] pr-40'
          )}
          value={customFunctionDescription}
          onChange={(e) => {
            if (isPredefined) {
              return
            }
            setCustomFunctionDescription(e.target.value)
          }}
          id=""
        ></textarea>
        {isPredefined && (
          <GraphicalIcon
            icon="readonly-lock"
            category="bootcamp"
            className="absolute right-[12px] top-[15px] opacity-[0.6]"
            width={20}
            height={20}
          />
        )}
      </div>

      <label className={labelClassName} htmlFor="fn-name">
        Tests
      </label>
    </div>
  )
}
