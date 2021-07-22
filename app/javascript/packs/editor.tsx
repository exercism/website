import React from 'react'
import { initReact } from '../utils/react-bootloader.jsx'

import '../../css/pages/editor'
import '../../css/modals/editor-hints'

import { Editor, Props } from '../components/Editor'

import { camelizeKeys } from 'humps'
function camelizeKeysAs<T>(object: any): T {
  return (camelizeKeys(object) as unknown) as T
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  editor: (data: any) => <Editor {...camelizeKeysAs<Props>(data)} />,
})
