import React from 'react'
import { Modifier } from '../types'
import { GraphicalIcon } from './GraphicalIcon'

type SearchInputProps = {
  value: string
  onChange: () => void
  placeholder: string
}

export default function SearchInput({
  value,
  onChange,
  placeholder,
}: SearchInputProps): JSX.Element {
  const WRAPPER_CLASSNAMES = `bg-unnamed15 border-1 border-transparent flex flex-row rounded-[5px] py-[12px] px-[21px] text-16 ${twModifier(
    'focus',
    'ring-1 ring-lightBlue'
  )}`
  const INPUT_CLASSNAMES = 'border-none bg-inherit'
  const ICON_CLASSNAMES = 'w-[24px] h-[24px] my-auto mr-[16px]'
  return (
    <div className={WRAPPER_CLASSNAMES}>
      <GraphicalIcon className={ICON_CLASSNAMES} icon="search" />
      <input
        type="text"
        className={INPUT_CLASSNAMES}
        style={{ all: 'unset' }}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
      />
    </div>
  )
}

function twModifier(modifier: Modifier, string: string): string {
  return `${modifier}:${string.split(' ').join(` ${modifier}:`)}`
}
