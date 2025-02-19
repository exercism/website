import React from 'react'

const labelClassName = 'font-mono font-semibold mb-4'
export function CustomFunctionDetails({
  name,
  setName,
  description,
  setDescription,
}: {
  name: string
  description: string
  setName: React.Dispatch<React.SetStateAction<string>>
  setDescription: React.Dispatch<React.SetStateAction<string>>
}) {
  return (
    <div className="flex flex-col mb-24">
      <label className={labelClassName} htmlFor="fn-name">
        Function name{' '}
      </label>
      <input
        className="mb-12"
        name="fn-name"
        type="text"
        readOnly
        value={name}
      />

      <label className={labelClassName} htmlFor="description">
        Description{' '}
      </label>
      <textarea
        name="description"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        id=""
      ></textarea>
    </div>
  )
}
