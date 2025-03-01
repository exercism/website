import React, { useContext } from 'react'
import { CustomFunctionEditorStoreContext } from './CustomFunctionEditor'
import { GraphicalIcon } from '@/components/common'

const labelClassName = 'text-16 font-semibold mb-8'
export function CustomFunctionDetails() {
  const { customFunctionEditorStore } = useContext(
    CustomFunctionEditorStoreContext
  )

  const {
    customFunctionName,
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
      <textarea
        name="description"
        className="mb-16"
        value={customFunctionDescription}
        onChange={(e) => setCustomFunctionDescription(e.target.value)}
        id=""
      ></textarea>

      <label className={labelClassName} htmlFor="fn-name">
        Tests
      </label>
    </div>
  )
}
