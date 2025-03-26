import React, { useContext } from 'react'
import { Tab } from '@/components/common'
import { FrontendTrainingPageContext } from '../../../FrontendTrainingPageContext'
import { SimpleCodeMirror } from '../../../SimpleCodeMirror/SimpleCodeMirror'
import { TabsContext } from '../../LHS'

export function CSSPanel() {
  const { handleCssEditorDidMount, LHSWidth } = useContext(
    FrontendTrainingPageContext
  )

  return (
    <Tab.Panel id="css" context={TabsContext}>
      <SimpleCodeMirror
        style={{ width: LHSWidth }}
        editorDidMount={handleCssEditorDidMount}
      />
    </Tab.Panel>
  )
}
