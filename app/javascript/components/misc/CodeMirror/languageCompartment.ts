import { StreamLanguage } from '@codemirror/language'
import { Compartment, Extension } from '@codemirror/state'

const compartment = new Compartment()

export const loadLanguageCompartment = async (
  language: string
): Promise<Extension> => {
  switch (language) {
    case 'cpp': {
      const { cpp } = await import('@codemirror/lang-cpp')
      return compartment.of(cpp())
    }
    case 'java': {
      const { java } = await import('@codemirror/lang-java')
      return compartment.of(java())
    }
    case 'cfml': {
      const { javascript: cfml } = await import('@codemirror/lang-javascript')
      return compartment.of(cfml())
    }
    case 'gleam': {
      const { gleam } = await import('@exercism/codemirror-lang-gleam')
      return compartment.of(gleam())
    }
    case 'javascript':
    case 'typescript': {
      const { javascript } = await import('@codemirror/lang-javascript')
      return compartment.of(javascript())
    }
    case 'jq': {
      const { jq } = await import('codemirror-lang-jq')
      return compartment.of(jq())
    }
    case 'php': {
      const { php } = await import('@codemirror/lang-php')
      return compartment.of(php())
    }
    case 'python': {
      const { python } = await import('@codemirror/lang-python')
      return compartment.of(python())
    }
    case 'rust': {
      const { rust } = await import('@codemirror/lang-rust')
      return compartment.of(rust())
    }
    case 'reasonml': {
      const { rust: reasonml } = await import('@codemirror/lang-rust')
      return compartment.of(reasonml())
    }
    case 'wren': {
      const { wren } = await import('@exercism/codemirror-lang-wren')
      return compartment.of(wren())
    }
    case 'zig': {
      const { rust: zig } = await import('@codemirror/lang-rust')
      return compartment.of(zig())
    }

    // Legacy
    case 'abap': {
      const { abapMode } = await import('codemirror6-abap')
      // @ts-ignore
      return compartment.of(StreamLanguage.define(abapMode))
    }
    case 'bash': {
      const { shell } = await import('@codemirror/legacy-modes/mode/shell')
      return compartment.of(StreamLanguage.define(shell))
    }
    case 'c': {
      const { c } = await import('@codemirror/legacy-modes/mode/clike')
      return compartment.of(StreamLanguage.define(c))
    }
    case 'ceylon': {
      const { ceylon } = await import('@codemirror/legacy-modes/mode/clike')
      return compartment.of(StreamLanguage.define(ceylon))
    }
    case 'clojure':
    case 'clojurescript': {
      const { clojure } = await import('@codemirror/legacy-modes/mode/clojure')
      return compartment.of(StreamLanguage.define(clojure))
    }
    case 'cobol': {
      const { cobol } = await import('@codemirror/legacy-modes/mode/cobol')
      return compartment.of(StreamLanguage.define(cobol))
    }
    case 'coffeescript': {
      const { coffeeScript } = await import(
        '@codemirror/legacy-modes/mode/coffeescript'
      )
      return compartment.of(StreamLanguage.define(coffeeScript))
    }
    case 'common-lisp':
    case 'emacs-lisp':
    case 'lfe': {
      const { commonLisp } = await import(
        '@codemirror/legacy-modes/mode/commonlisp'
      )
      return compartment.of(StreamLanguage.define(commonLisp))
    }
    case 'crystal': {
      const { crystal } = await import('@codemirror/legacy-modes/mode/crystal')
      return compartment.of(StreamLanguage.define(crystal))
    }
    case 'csharp': {
      const { csharp } = await import('@codemirror/legacy-modes/mode/clike')
      return compartment.of(StreamLanguage.define(csharp))
    }
    case 'd': {
      const { d } = await import('@codemirror/legacy-modes/mode/d')
      return compartment.of(StreamLanguage.define(d))
    }
    case 'dart': {
      const { dart } = await import('@codemirror/legacy-modes/mode/clike')
      return compartment.of(StreamLanguage.define(dart))
    }
    case 'delphi': {
      const { pascal } = await import('@codemirror/legacy-modes/mode/pascal')
      return compartment.of(StreamLanguage.define(pascal))
    }
    case 'elm': {
      const { elm } = await import('@codemirror/legacy-modes/mode/elm')
      return compartment.of(StreamLanguage.define(elm))
    }
    case 'erlang': {
      const { erlang } = await import('@codemirror/legacy-modes/mode/erlang')
      return compartment.of(StreamLanguage.define(erlang))
    }
    case 'factor': {
      const { factor } = await import('@codemirror/legacy-modes/mode/factor')
      return compartment.of(StreamLanguage.define(factor))
    }
    case 'forth': {
      const { forth } = await import('@codemirror/legacy-modes/mode/forth')
      return compartment.of(StreamLanguage.define(forth))
    }
    case 'fortran': {
      const { fortran } = await import('@codemirror/legacy-modes/mode/fortran')
      return compartment.of(StreamLanguage.define(fortran))
    }
    case 'fsharp': {
      const { fSharp } = await import('@codemirror/legacy-modes/mode/mllike')
      return compartment.of(StreamLanguage.define(fSharp))
    }
    case 'gnu-apl': {
      const { apl } = await import('@codemirror/legacy-modes/mode/apl')
      return compartment.of(StreamLanguage.define(apl))
    }
    case 'go': {
      const { go } = await import('@codemirror/legacy-modes/mode/go')
      return compartment.of(StreamLanguage.define(go))
    }
    case 'groovy': {
      const { groovy } = await import('@codemirror/legacy-modes/mode/groovy')
      return compartment.of(StreamLanguage.define(groovy))
    }
    case 'haskell':
    case 'purescript':
    case 'unison': {
      const { haskell } = await import('@codemirror/legacy-modes/mode/haskell')
      return compartment.of(StreamLanguage.define(haskell))
    }
    case 'haxe': {
      const { haxe } = await import('@codemirror/legacy-modes/mode/haxe')
      return compartment.of(StreamLanguage.define(haxe))
    }
    case 'kotlin': {
      const { kotlin } = await import('@codemirror/legacy-modes/mode/clike')
      return compartment.of(StreamLanguage.define(kotlin))
    }
    case 'lua': {
      const { lua } = await import('@codemirror/legacy-modes/mode/lua')
      return compartment.of(StreamLanguage.define(lua))
    }
    case 'objective-c': {
      const { objectiveC } = await import('@codemirror/legacy-modes/mode/clike')
      return compartment.of(StreamLanguage.define(objectiveC))
    }
    case 'ocaml': {
      const { oCaml } = await import('@codemirror/legacy-modes/mode/mllike')
      return compartment.of(StreamLanguage.define(oCaml))
    }
    case 'perl5':
    case 'raku': {
      const { perl } = await import('@codemirror/legacy-modes/mode/perl')
      return compartment.of(StreamLanguage.define(perl))
    }
    case 'pharo-smalltalk': {
      const { smalltalk } = await import(
        '@codemirror/legacy-modes/mode/smalltalk'
      )
      return compartment.of(StreamLanguage.define(smalltalk))
    }
    case 'plsql': {
      const { plSQL } = await import('@codemirror/legacy-modes/mode/sql')
      return compartment.of(StreamLanguage.define(plSQL))
    }
    case 'powershell': {
      const { powerShell } = await import(
        '@codemirror/legacy-modes/mode/powershell'
      )
      return compartment.of(StreamLanguage.define(powerShell))
    }
    case 'r': {
      const { r } = await import('@codemirror/legacy-modes/mode/r')
      return compartment.of(StreamLanguage.define(r))
    }
    case 'ruby': {
      const { ruby } = await import('@codemirror/legacy-modes/mode/ruby')
      return compartment.of(StreamLanguage.define(ruby))
    }
    case 'scala': {
      const { scala } = await import('@codemirror/legacy-modes/mode/clike')
      return compartment.of(StreamLanguage.define(scala))
    }
    case 'racket':
    case 'scheme': {
      const { scheme } = await import('@codemirror/legacy-modes/mode/scheme')
      return compartment.of(StreamLanguage.define(scheme))
    }
    case 'sml': {
      const { sml } = await import('@codemirror/legacy-modes/mode/mllike')
      return compartment.of(StreamLanguage.define(sml))
    }
    case 'sqlite': {
      const { sqlite } = await import('@codemirror/legacy-modes/mode/sql')
      return compartment.of(StreamLanguage.define(sqlite))
    }
    case 'swift': {
      const { swift } = await import('@codemirror/legacy-modes/mode/swift')
      return compartment.of(StreamLanguage.define(swift))
    }
    case 'system-verilog': {
      const { verilog } = await import('@codemirror/legacy-modes/mode/verilog')
      return compartment.of(StreamLanguage.define(verilog))
    }
    case 'tcl': {
      const { tcl } = await import('@codemirror/legacy-modes/mode/tcl')
      return compartment.of(StreamLanguage.define(tcl))
    }
    case 'vbnet': {
      const { vb } = await import('@codemirror/legacy-modes/mode/vb')
      return compartment.of(StreamLanguage.define(vb))
    }
    case 'wasm': {
      const { wast } = await import('@codemirror/legacy-modes/mode/wast')
      return compartment.of(StreamLanguage.define(wast))
    }
    case 'x86-64-assembly': {
      const { gas } = await import('@codemirror/legacy-modes/mode/gas')
      return compartment.of(StreamLanguage.define(gas))
    }
    // Custom
    case 'elixir': {
      const { elixir } = await import('codemirror-lang-elixir')
      // @ts-ignore
      return compartment.of(StreamLanguage.define(elixir))
    }
    case 'nim': {
      const { nim } = await require('nim-codemirror-mode')
      return compartment.of(StreamLanguage.define(nim({}, {})))
    }
    case 'julia': {
      const { julia } = await import('lang-julia')
      return compartment.of(julia())
    }
    default:
      return []
  }
}
