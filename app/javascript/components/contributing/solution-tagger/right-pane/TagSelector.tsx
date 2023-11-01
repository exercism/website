import React from 'react'
import CreatableSelect from 'react-select/creatable'

const options = [
  { value: 'chocolate', label: 'Chocolate' },
  { value: 'strawberry', label: 'Strawberry' },
  { value: 'vanilla', label: 'Vanilla' },
]
export function TagSelector({
  tags,
}: {
  tags: Record<string, string>
}): JSX.Element {
  return (
    <CreatableSelect
      className="creatable-select-component"
      isMulti
      options={transformObject(tags)}
      onChange={(e) => console.log(e)}
    />
  )
}

function transformObject(obj: Record<string, string>) {
  return Object.entries(obj).map(([key, value]) => ({
    label: key,
    value: value,
  }))
}
