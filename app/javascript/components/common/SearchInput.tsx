import React from 'react'
import { Modifier } from '../types'
import { GraphicalIcon } from './GraphicalIcon'

type SearchInputProps = {
  value: string
  onChange: () => void
  placeholder: string
}

const FW = 'focus-within:border-lightBlue focus-within:bg-white'
const WRAPPER_CLASSNAMES = `${FW} bg-unnamed15 border-1 border-transparent flex flex-row rounded-[5px] py-[12px] px-[21px] text-16 `
const INPUT_CLASSNAMES = 'border-none bg-inherit'
const ICON_CLASSNAMES = 'w-[24px] h-[24px] my-auto mr-[16px]'

export default function SearchInput({
  value,
  onChange,
  placeholder,
}: SearchInputProps): JSX.Element {
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
