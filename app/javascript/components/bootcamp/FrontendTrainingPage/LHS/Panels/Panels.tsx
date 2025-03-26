import React from 'react'
import { CSSPanel } from './CSSPanel/CSSPanel'
import { HTMLPanel } from './HTMLPanel/HTMLPanel'

export function Panels() {
  return (
    <>
      <HTMLPanel />
      <CSSPanel />
    </>
  )
}
