import React, { useState, useEffect, useRef } from 'react'
import { EditorView, keymap, KeyBinding } from '@codemirror/view'
import { basicSetup } from '@codemirror/basic-setup'
import { EditorState, Compartment, StateEffect } from '@codemirror/state'
import { indentUnit } from '@codemirror/language'
import { Themes } from '../editor/types'
import { loadLanguageCompartment } from './CodeMirror/languageCompartment'
import { a11yTabBindingPanel } from './CodeMirror/a11yTabBinding'
import { useTabBinding } from './CodeMirror/use-tab-binding'

const wrapCompartment = new Compartment()
const themeCompartment = new Compartment()
const tabCaptureCompartment = new Compartment()
const keymapCompartment = new Compartment()

export type Handler = {
  setValue: (value: string) => void
  getValue: () => string
}
export const CodeMirror = ({
  value,
  language,
  commands,
  theme,
  wrap,
  useSoftTabs,
  tabSize,
  isTabCaptured,
  editorDidMount,
}: {
  value: string
  language: string
  theme: Themes
  commands: KeyBinding[]
  wrap: boolean
  useSoftTabs: boolean
  isTabCaptured: boolean
  tabSize: number
  editorDidMount: (handler: Handler) => void
}): JSX.Element => {
  const [textarea, setTextarea] = useState<HTMLDivElement | null>(null)
  const viewRef = useRef<EditorView | null>(null)

  const setValue = (text: string) => {
    if (!viewRef.current) {
      return
    }

    const transaction = viewRef.current.state.update({
      changes: {
        from: 0,
        to: viewRef.current.state.doc.length,
        insert: text,
      },
    })

    viewRef.current.dispatch(transaction)
  }

  const getValue = () => {
    return (value = viewRef.current?.state.doc.toString() || '')
  }

  const indentChar = Array.from({ length: tabSize }, () => ' ').join('')
  const tabBinding = useTabBinding(indentChar, useSoftTabs)

  useEffect(() => {
    if (!textarea) {
      return
    }

    if (viewRef.current) {
      return
    }

    const view = new EditorView({
      state: EditorState.create({
        doc: value,
        extensions: [
          keymapCompartment.of(keymap.of(commands)),
          basicSetup,
          a11yTabBindingPanel(),
          tabCaptureCompartment.of(
            keymap.of(isTabCaptured ? [tabBinding] : [])
          ),
          indentUnit.of(indentChar),
          wrapCompartment.of(wrap ? EditorView.lineWrapping : []),
          themeCompartment.of(
            EditorView.theme({}, { dark: theme === Themes.DARK })
          ),
        ],
      }),
      parent: textarea,
    })

    viewRef.current = view

    editorDidMount({ setValue, getValue })

    // Lazy-load the language extension, which allows us to import just
    // the extension's code for the current language
    loadLanguageCompartment(language).then((languageExtension) => {
      view.dispatch({
        effects: StateEffect.appendConfig.of(languageExtension),
      })
    })
  })

  useEffect(() => {
    if (!viewRef.current) {
      return
    }

    viewRef.current.dispatch({
      effects: wrapCompartment.reconfigure(wrap ? EditorView.lineWrapping : []),
    })
  }, [wrap])

  useEffect(() => {
    if (!viewRef.current) {
      return
    }

    viewRef.current.dispatch({
      effects: themeCompartment.reconfigure(
        EditorView.theme({}, { dark: theme === Themes.DARK })
      ),
    })
  }, [theme])

  useEffect(() => {
    if (!viewRef.current) {
      return
    }

    viewRef.current.dispatch({
      effects: tabCaptureCompartment.reconfigure(
        keymap.of(isTabCaptured ? [tabBinding] : [])
      ),
    })
  }, [isTabCaptured, tabBinding])

  useEffect(() => {
    if (!viewRef.current) {
      return
    }

    viewRef.current.dispatch({
      effects: keymapCompartment.reconfigure(keymap.of(commands)),
    })
  }, [commands])

  return <div className="editor" ref={setTextarea} />
}
