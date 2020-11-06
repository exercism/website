import React from 'react'

import { Bootloader } from './bootloader'

export function wrap(name, Tag, tagProps, Contents) {
  const wrapped = function (props) {
    return (
      <Tag {...tagProps}>
        <Contents {...props} />
      </Tag>
    )
  }

  Bootloader[name] = Contents
  wrapped.displayName = `${Tag}(${getDisplayName(Contents)})`
  return wrapped
}

function getDisplayName(WrappedComponent) {
  return WrappedComponent.displayName || WrappedComponent.name || 'Component'
}
