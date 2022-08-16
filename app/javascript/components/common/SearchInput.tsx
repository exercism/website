import React, { ChangeEventHandler, useRef, useState } from 'react'
// import { Modifier } from '../types'
import { GraphicalIcon } from './GraphicalIcon'

type SearchInputProps = {
  value: string
  onChange: ChangeEventHandler<HTMLInputElement>
  placeholder: string
}

const WRAPPER_CLASSNAMES =
  'bg-unnamed15 flex flex-row rounded-[5px] border-1 border-transparent py-[11px] px-[21px] text-16 w-[420px] focus-within:focused-input hover:cursor-text'

const INPUT_CLASSNAMES = 'border-none bg-inherit !w-[100%]'
const ICON_CLASSNAMES = 'w-[24px] h-[24px] my-auto mr-[16px] magnifier-filter'

export default function SearchInput({
  value,
  onChange,
  placeholder,
}: SearchInputProps): JSX.Element {
  const searchInputRef = useRef<HTMLInputElement>(null)
  const [focused, setFocused] = useState<boolean>(false)

  const focusInputElement = () => {
    searchInputRef.current?.focus()
  }

  return (
    <div className={WRAPPER_CLASSNAMES} onClick={focusInputElement}>
      <GraphicalIcon
        className={ICON_CLASSNAMES + (focused ? 'filter-none' : '')}
        icon="search"
      />
      <input
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        ref={searchInputRef}
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

// function twModifier(modifier: Modifier, string: string): string {
//   return `${modifier}:${string.split(' ').join(` ${modifier}:`)}`
// }

// const focusWithin = twModifier.bind(null, 'focus-within');
// const hover = twModifier.bind(null, 'hover');
// const WRAPPER_CLASSNAMES = ['bg-unnamed15 border-1 border-transparent flex flex-row rounded-[5px] py-[12px] px-[21px] text-16 w-[420px]', focusWithin('bg-white border-lightBlue shadow-inputSelected'),hover('bg-lightBrown') ].join(' ')
