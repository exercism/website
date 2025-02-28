import React, { useContext } from 'react'
import { CustomFunctionEditorStoreContext } from './CustomFunctionEditor'

const labelClassName = 'text-16 font-semibold mb-8'
export function CustomFunctionDetails() {
  const { customFunctionEditorStore } = useContext(
    CustomFunctionEditorStoreContext
  )

  const {
    customFunctionDisplayName,
    customFunctionDescription,
    setCustomFunctionDescription,
  } = customFunctionEditorStore()

  return (
    <div className="flex flex-col">
      <label className={labelClassName} htmlFor="fn-name">
        Function name
      </label>
      <input
        className="mb-16"
        name="fn-name"
        type="text"
        readOnly
        value={customFunctionDisplayName}
      />
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
