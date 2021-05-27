import { StreamLanguage } from '@codemirror/stream-parser'
import { Compartment, Extension } from '@codemirror/state'

const compartment = new Compartment()

export const loadLanguageCompartment = async (
  language: string
): Promise<Extension> => {
  switch (language) {
    case 'javascript':
      const { javascript } = await import('@codemirror/lang-javascript')
      return compartment.of(javascript())
    case 'cpp':
      const { cpp } = await import('@codemirror/lang-cpp')
      return compartment.of(cpp())
    case 'java':
      const { java } = await import('@codemirror/lang-java')
      return compartment.of(java())
    case 'rust':
      const { rust } = await import('@codemirror/lang-rust')
      return compartment.of(rust())
    case 'python':
      const { python } = await import('@codemirror/lang-python')
      return compartment.of(python())

    // Legacy
    case 'ruby':
      const { ruby } = await import('@codemirror/legacy-modes/mode/ruby')
      return compartment.of(StreamLanguage.define(ruby))
    case 'csharp':
      const { csharp } = await import('@codemirror/legacy-modes/mode/clike')
      return compartment.of(StreamLanguage.define(csharp))

    // Exceptions
    case 'elixir':
      const { elixir } = await import('codemirror-lang-elixir')
      return compartment.of(StreamLanguage.define(elixir))
    default:
      return []
  }
}
