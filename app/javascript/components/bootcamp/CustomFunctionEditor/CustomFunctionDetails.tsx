import React, { useContext } from 'react'
import { CustomFunctionEditorStoreContext } from './CustomFunctionEditor'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'

const labelClassName = 'text-16 font-semibold mb-8'
export function CustomFunctionDetails() {
  const { customFunctionEditorStore } = useContext(
    CustomFunctionEditorStoreContext
  )

  const {
    customFunctionName,
    isPredefined,
    customFunctionDescription,
    setCustomFunctionDescription,
  } = customFunctionEditorStore()

  return (
    <div className="flex flex-col">
      <label className={labelClassName} htmlFor="fn-name">
        Function name
      </label>
      <div className="relative">
        <input
          className="mb-16 !bg-[#eee] w-fill"
          name="fn-name"
          type="text"
          readOnly
          value={customFunctionName}
        />
        <GraphicalIcon
          icon="readonly-lock"
          category="bootcamp"
          className="absolute right-[12px] top-[15px]"
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
            isPredefined && '!bg-[#eee]'
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
            className="absolute right-[12px] top-[15px]"
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
