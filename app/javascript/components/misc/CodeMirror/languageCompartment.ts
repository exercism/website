import { StreamLanguage } from '@codemirror/stream-parser'
import { Compartment, Extension } from '@codemirror/state'

import { ruby } from '@codemirror/legacy-modes/mode/ruby'
import { elixir } from 'codemirror-lang-elixir'

import { javascript } from '@codemirror/lang-javascript'
import { cpp } from '@codemirror/lang-cpp'
import { java } from '@codemirror/lang-java'
import { rust } from '@codemirror/lang-rust'
import { python } from '@codemirror/lang-python'

const compartment = new Compartment()

export const languageCompartment = (language: string): Extension => {
  switch (language) {
    case 'ruby':
      return compartment.of(StreamLanguage.define(ruby))
    case 'javascript':
      return compartment.of(javascript())
    case 'cpp':
      return compartment.of(cpp())
    case 'java':
      return compartment.of(java())
    case 'rust':
      return compartment.of(rust())
    case 'python':
      return compartment.of(python())
    case 'elixir':
      return compartment.of(StreamLanguage.define(elixir))
    default:
      return []
  }
}
