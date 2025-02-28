import React, { useContext } from 'react'
import { CustomFunctionEditorStoreContext } from './CustomFunctionEditor'

const labelClassName = 'font-mono font-semibold mb-4'
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
    <div className="flex flex-col mb-24">
      <label className={labelClassName} htmlFor="fn-name">
        Function name{' '}
      </label>
      <input
        className="mb-24"
        name="fn-name"
        type="text"
        readOnly
        value={customFunctionDisplayName}
      />
      <label className={labelClassName} htmlFor="description">
        Description{' '}
      </label>
      <textarea
        name="description"
        value={customFunctionDescription}
        onChange={(e) => setCustomFunctionDescription(e.target.value)}
        id=""
      ></textarea>
    </div>
  )
}
