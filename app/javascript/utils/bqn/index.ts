/**
 * Editor support for BQN.
 */
import * as Autocomplete from '@codemirror/autocomplete'
import { HighlightStyle, Tag, styleTags } from '@codemirror/highlight'
import * as Highlight from '@codemirror/highlight'
import {
  LRLanguage,
  LanguageSupport,
  delimitedIndent,
  indentNodeProp,
} from '@codemirror/language'
import * as State from '@codemirror/state'
import * as View from '@codemirror/view'
import { parser } from './bqn.grammar'

let tags = {
  BQNval: Tag.define(),
  BQNstring: Tag.define(),
  BQNnumber: Tag.define(),
  BQNnothing: Tag.define(),
  BQNparen: Tag.define(),
  BQNdelim: Tag.define(),
  BQNlist: Tag.define(),
  BQNblock: Tag.define(),
  BQNfun: Tag.define(),
  BQNmod1: Tag.define(),
  BQNmod2: Tag.define(),
  BQNcomment: Tag.define(),
}

export let highlightLight = HighlightStyle.define(
  [
    { tag: tags.BQNval, color: '#444' },
    { tag: tags.BQNstring, color: '#3e99ab' },
    { tag: tags.BQNnumber, color: '#a73227' },
    { tag: tags.BQNnothing, color: '#a73227' },
    { tag: tags.BQNparen, color: '#5a524a' },
    { tag: tags.BQNdelim, color: '#9c7dc1' },
    { tag: tags.BQNlist, color: '#9c7dc1' },
    { tag: tags.BQNblock, color: '#862f9e' },
    { tag: tags.BQNfun, color: '#3aa548' },
    { tag: tags.BQNmod1, color: '#93428b' },
    { tag: tags.BQNmod2, color: '#998819' },
    { tag: tags.BQNcomment, color: '#3f3daa' },
  ],
  { themeType: 'light' }
)

export let highlightDark = HighlightStyle.define(
  [
    { tag: tags.BQNval, color: '#eee' },
    { tag: tags.BQNstring, color: '#3e99ab' },
    { tag: tags.BQNnumber, color: '#a73227' },
    { tag: tags.BQNnothing, color: '#a73227' },
    { tag: tags.BQNparen, color: '#5a524a' },
    { tag: tags.BQNdelim, color: '#9c7dc1' },
    { tag: tags.BQNlist, color: '#9c7dc1' },
    { tag: tags.BQNblock, color: '#862f9e' },
    { tag: tags.BQNfun, color: '#3aa548' },
    { tag: tags.BQNmod1, color: '#93428b' },
    { tag: tags.BQNmod2, color: '#998819' },
    { tag: tags.BQNcomment, color: '#3f3daa' },
  ],
  { themeType: 'dark' }
)

let bqnStyleTags = styleTags({
  COMMENT: tags.BQNcomment,
  STRING: tags.BQNstring,
  CHAR: tags.BQNstring,
  NULL: tags.BQNstring,
  NUMBER: tags.BQNnumber,
  NOTHING: tags.BQNnothing,
  PAREN: tags.BQNparen,
  DELIM: tags.BQNdelim,
  STRIDE: tags.BQNdelim,
  LIST: tags.BQNlist,
  BLOCK: tags.BQNblock,
  FUN: tags.BQNfun,
  PRIMFUN: tags.BQNfun,
  SYSFUN: tags.BQNfun,
  SPECFUN: tags.BQNfun,
  MOD1: tags.BQNmod1,
  PRIMMOD1: tags.BQNmod1,
  SYSMOD1: tags.BQNmod1,
  MOD2: tags.BQNmod2,
  PRIMMOD2: tags.BQNmod2,
  SYSMOD2: tags.BQNmod2,
  SPECMOD2: tags.BQNmod2,
  VAL: tags.BQNval,
})

export let language = LRLanguage.define({
  parser: parser.configure({
    props: [
      bqnStyleTags,
      indentNodeProp.add({
        BLOCK: delimitedIndent({ closing: '}', align: true }),
      }),
    ],
  }),
  languageData: {
    commentTokens: { line: '#' },
    indentOnInput: /^\s*(\]|}|⟩)$/,
    closeBrackets: { brackets: ['(', '{', '⟨', '[', "'", '"'] },
  },
})

export type Glyph = {
  glyph: string
  key: string | null
  tag: Tag
  title: string
}

export let glyphs: Glyph[] = [
  {
    glyph: '+',
    title: 'Conjuage/Add',
    tag: tags.BQNfun,
    key: null,
  },
  {
    glyph: '-',
    title: 'Negate/Substract',
    tag: tags.BQNfun,
    key: null,
  },
  {
    glyph: '×',
    title: 'Sign/Multiply',
    tag: tags.BQNfun,
    key: '=',
  },
  {
    glyph: '÷',
    title: 'Reciprocal/Divide',
    tag: tags.BQNfun,
    key: '-',
  },
  {
    glyph: '⋆',
    title: 'Exponential/Power',
    tag: tags.BQNfun,
    key: '+',
  },
  {
    glyph: '√',
    title: 'Square root/Root',
    tag: tags.BQNfun,
    key: '_',
  },
  {
    glyph: '⌊',
    title: 'Floor/Minimum',
    tag: tags.BQNfun,
    key: 'b',
  },
  {
    glyph: '⌈',
    title: 'Celing/Maximum',
    tag: tags.BQNfun,
    key: 'B',
  },
  {
    glyph: '∧',
    title: 'Sort up/And',
    tag: tags.BQNfun,
    key: 't',
  },
  {
    glyph: '∨',
    title: 'Sort down/Or',
    tag: tags.BQNfun,
    key: 'v',
  },
  {
    glyph: '¬',
    title: 'Not/Span',
    tag: tags.BQNfun,
    key: '~',
  },
  {
    glyph: '|',
    title: 'Absolute value/Modulus',
    tag: tags.BQNfun,
    key: null,
  },
  {
    glyph: '≤',
    title: 'Less than or equal to',
    tag: tags.BQNfun,
    key: '<',
  },
  {
    glyph: '<',
    title: 'Enclose/Less than',
    tag: tags.BQNfun,
    key: null,
  },
  {
    glyph: '>',
    title: 'Merge/Greater than',
    tag: tags.BQNfun,
    key: null,
  },
  {
    glyph: '≥',
    title: 'Greater than or equal to',
    tag: tags.BQNfun,
    key: '>',
  },
  {
    glyph: '=',
    title: 'Rank/Equals',
    tag: tags.BQNfun,
    key: null,
  },
  {
    glyph: '≠',
    title: 'Length/Not equals',
    tag: tags.BQNfun,
    key: '/',
  },
  {
    glyph: '≡',
    title: 'Depth/Match',
    tag: tags.BQNfun,
    key: 'm',
  },
  {
    glyph: '≢',
    title: 'Shape/Not match',
    tag: tags.BQNfun,
    key: 'M',
  },
  {
    glyph: '⊣',
    title: 'Identity/Left',
    tag: tags.BQNfun,
    key: '{',
  },
  {
    glyph: '⊢',
    title: 'Identity/Right',
    tag: tags.BQNfun,
    key: '}',
  },
  {
    glyph: '⥊',
    title: 'Deshape/Reshape',
    tag: tags.BQNfun,
    key: 'z',
  },
  {
    glyph: '∾',
    title: 'Join/Join to',
    tag: tags.BQNfun,
    key: ',',
  },
  {
    glyph: '≍',
    title: 'Solo/Couple',
    tag: tags.BQNfun,
    key: '.',
  },
  {
    glyph: '⋈',
    title: 'Enlist/Pair',
    tag: tags.BQNfun,
    key: 'Z',
  },
  {
    glyph: '↑',
    title: 'Prefixes/Take',
    tag: tags.BQNfun,
    key: 'r',
  },
  {
    glyph: '↓',
    title: 'Suffixes/Drop',
    tag: tags.BQNfun,
    key: 'c',
  },
  {
    glyph: '↕',
    title: 'Range/Windows',
    tag: tags.BQNfun,
    key: 'd',
  },
  {
    glyph: '«',
    title: 'Shift before',
    tag: tags.BQNfun,
    key: 'H',
  },
  {
    glyph: '»',
    title: 'Shift after',
    tag: tags.BQNfun,
    key: 'L',
  },
  {
    glyph: '⌽',
    title: 'Reverse/Rotate',
    tag: tags.BQNfun,
    key: 'q',
  },
  {
    glyph: '⍉',
    title: 'Transpose/Reorder axis',
    tag: tags.BQNfun,
    key: 'a',
  },
  {
    glyph: '/',
    title: 'Indices/Replicate',
    tag: tags.BQNfun,
    key: null,
  },
  {
    glyph: '⍋',
    title: 'Grade up/Bins up',
    tag: tags.BQNfun,
    key: 'T',
  },
  {
    glyph: '⍒',
    title: 'Grade down/Bins down',
    tag: tags.BQNfun,
    key: 'V',
  },
  {
    glyph: '⊏',
    title: 'First cell/Select',
    tag: tags.BQNfun,
    key: 'i',
  },
  {
    glyph: '⊑',
    title: 'First/Pick',
    tag: tags.BQNfun,
    key: 'I',
  },
  {
    glyph: '⊐',
    title: 'Classify/Index of',
    tag: tags.BQNfun,
    key: 'o',
  },
  {
    glyph: '⊒',
    title: 'Occurrence count/Progressive index of',
    tag: tags.BQNfun,
    key: 'O',
  },
  {
    glyph: '∊',
    title: 'Mark first/Member of',
    tag: tags.BQNfun,
    key: 'e',
  },
  {
    glyph: '⍷',
    title: 'Deduplicate/Find',
    tag: tags.BQNfun,
    key: 'E',
  },
  {
    glyph: '⊔',
    title: 'Group indices/Group',
    tag: tags.BQNfun,
    key: 'u',
  },
  {
    glyph: '!',
    title: 'Assert/Assert with message',
    tag: tags.BQNfun,
    key: null,
  },
  {
    glyph: '˙',
    title: 'Constant',
    tag: tags.BQNmod1,
    key: '"',
  },
  {
    glyph: '˜',
    title: 'Self/Swap',
    tag: tags.BQNmod1,
    key: '`',
  },
  {
    glyph: '∘',
    title: 'Atop',
    tag: tags.BQNmod2,
    key: 'j',
  },
  {
    glyph: '○',
    title: 'Over',
    tag: tags.BQNmod2,
    key: 'k',
  },
  {
    glyph: '⊸',
    title: 'Before/Bind',
    tag: tags.BQNmod2,
    key: 'h',
  },
  {
    glyph: '⟜',
    title: 'After/Bind',
    tag: tags.BQNmod2,
    key: 'l',
  },
  {
    glyph: '⌾',
    title: 'Under',
    tag: tags.BQNmod2,
    key: 'K',
  },
  {
    glyph: '⊘',
    title: 'Valences',
    tag: tags.BQNmod2,
    key: '%',
  },
  {
    glyph: '◶',
    title: 'Choose',
    tag: tags.BQNmod2,
    key: '$',
  },
  {
    glyph: '⎊',
    title: 'Catch',
    tag: tags.BQNmod2,
    key: '^',
  },
  {
    glyph: '⎉',
    title: 'Rank',
    tag: tags.BQNmod2,
    key: '!',
  },
  {
    glyph: '˘',
    title: 'Cells',
    tag: tags.BQNmod1,
    key: '1',
  },
  {
    glyph: '⚇',
    title: 'Depth',
    tag: tags.BQNmod2,
    key: '@',
  },
  {
    glyph: '¨',
    title: 'Each',
    tag: tags.BQNmod1,
    key: '2',
  },
  {
    glyph: '⌜',
    title: 'Table',
    tag: tags.BQNmod1,
    key: '4',
  },
  {
    glyph: '⍟',
    title: 'Repeat',
    tag: tags.BQNmod2,
    key: '#',
  },
  {
    glyph: '⁼',
    title: 'Undo',
    tag: tags.BQNmod1,
    key: '3',
  },
  {
    glyph: '´',
    title: 'Fold',
    tag: tags.BQNmod1,
    key: '5',
  },
  {
    glyph: '˝',
    title: 'Insert',
    tag: tags.BQNmod1,
    key: '6',
  },
  {
    glyph: '`',
    title: 'Scan',
    tag: tags.BQNmod1,
    key: null,
  },
  {
    glyph: '←',
    title: 'Define',
    tag: tags.BQNval,
    key: '[',
  },
  {
    glyph: '⇐',
    title: 'Export',
    tag: tags.BQNval,
    key: '?',
  },
  {
    glyph: '↩',
    title: 'Change',
    tag: tags.BQNval,
    key: "'",
  },
  {
    glyph: '⋄',
    title: 'Separator',
    tag: tags.BQNlist,
    key: ';',
  },
  {
    glyph: ',',
    title: 'Separator',
    tag: tags.BQNval,
    key: null,
  },
  {
    glyph: '.',
    title: 'Namespace field',
    tag: tags.BQNval,
    key: null,
  },
  {
    glyph: '(',
    title: 'Begin expression',
    tag: tags.BQNval,
    key: null,
  },
  {
    glyph: ')',
    title: 'End expression',
    tag: tags.BQNval,
    key: null,
  },
  {
    glyph: '{',
    title: 'Begin block',
    tag: tags.BQNblock,
    key: null,
  },
  {
    glyph: '}',
    title: 'End block',
    tag: tags.BQNblock,
    key: null,
  },
  {
    glyph: ';',
    title: 'Next body',
    tag: tags.BQNval,
    key: null,
  },
  {
    glyph: ':',
    title: 'Header',
    tag: tags.BQNval,
    key: null,
  },
  {
    glyph: '?',
    title: 'Predicate',
    tag: tags.BQNval,
    key: null,
  },
  {
    glyph: '⟨',
    title: 'Begin list',
    tag: tags.BQNlist,
    key: '(',
  },
  {
    glyph: '⟩',
    title: 'End list',
    tag: tags.BQNlist,
    key: ')',
  },
  {
    glyph: '‿',
    title: 'Strand',
    tag: tags.BQNlist,
    key: ' ',
  },
  {
    glyph: '·',
    title: 'Nothing',
    tag: tags.BQNnothing,
    key: ':',
  },
  {
    glyph: '•',
    title: 'System',
    tag: tags.BQNval,
    key: '0',
  },
  {
    glyph: '𝕨',
    title: 'Left argument',
    tag: tags.BQNval,
    key: 'w',
  },
  {
    glyph: '𝕎',
    title: 'Left argument (as function)',
    tag: tags.BQNfun,
    key: 'W',
  },
  {
    glyph: '𝕩',
    title: 'Right argument',
    tag: tags.BQNval,
    key: 'x',
  },
  {
    glyph: '𝕏',
    title: 'Right argument (as function)',
    tag: tags.BQNfun,
    key: 'X',
  },
  {
    glyph: '𝕗',
    title: 'Modifier left operand',
    tag: tags.BQNval,
    key: 'f',
  },
  {
    glyph: '𝔽',
    title: 'Modifier left operand (as function)',
    tag: tags.BQNfun,
    key: 'F',
  },
  {
    glyph: '𝕘',
    title: 'Modifier right operand',
    tag: tags.BQNval,
    key: 'g',
  },
  {
    glyph: '𝔾',
    title: 'Modifier right operand (as function)',
    tag: tags.BQNfun,
    key: 'G',
  },
  {
    glyph: '𝕤',
    title: 'Current function (as subject)',
    tag: tags.BQNval,
    key: 's',
  },
  {
    glyph: '𝕊',
    title: 'Current function',
    tag: tags.BQNfun,
    key: 'S',
  },
  {
    glyph: '𝕣',
    title: 'Current modifier',
    tag: tags.BQNmod2,
    key: 'R',
  },
  {
    glyph: '¯',
    title: 'Minus',
    tag: tags.BQNnumber,
    key: '9',
  },
  {
    glyph: 'π',
    title: 'Pi',
    tag: tags.BQNnumber,
    key: 'p',
  },
  {
    glyph: '∞',
    title: 'Infinity',
    tag: tags.BQNnumber,
    key: '8',
  },
  {
    glyph: '@',
    title: 'Null character',
    tag: tags.BQNstring,
    key: null,
  },
  {
    glyph: '#',
    title: 'Comment',
    tag: tags.BQNcomment,
    key: null,
  },
]

export let glyphsMap: Map<string, Glyph> = new Map()
for (let glyph of glyphs) glyphsMap.set(glyph.glyph, glyph)

export let keymap: Map<string, Glyph> = new Map()
for (let glyph of glyphs) if (glyph.key != null) keymap.set(glyph.key, glyph)

/**
 * BQN glyph input method using \-key as a dead key prefix.
 */
function glyphInputMethod(): State.Extension {
  type InputState = {
    timeout: NodeJS.Timeout
    editorState: State.EditorState
  }

  type DeadKeyState = null | {
    phase: 'dead' | 'after-dead'
    editorState: State.EditorState
  }

  let thisView: View.EditorView | null = null
  let prevEditorState: State.EditorState | null = null
  let deadKeyState: DeadKeyState | null = null
  let inputState: InputState | null = null

  let resetExpecting = () => {
    if (inputState != null) {
      clearTimeout(inputState.timeout)
      inputState = null
    }
  }

  let scheduleExpecting = (editorState: State.EditorState) => {
    resetExpecting()
    inputState = {
      editorState,
      timeout: setTimeout(() => {
        let editorState = inputState?.editorState
        inputState = null
        if (thisView != null && editorState === thisView.state)
          Autocomplete.startCompletion(thisView)
      }, 1000),
    }
  }

  let lifecycle = View.ViewPlugin.fromClass(
    class {
      constructor(view: View.EditorView) {
        thisView = view
      }
      destroy() {
        resetExpecting()
        thisView = null
      }
    }
  )

  let updateListener = View.EditorView.updateListener.of((up) => {
    prevEditorState = up.startState
  })

  function skipDueToDeadKey(ev: KeyboardEvent, view: View.EditorView) {
    if (ev.key === 'Dead') {
      deadKeyState = { phase: 'dead', editorState: view.state }
      return true
    }
    if (
      deadKeyState?.phase === 'dead' &&
      deadKeyState?.editorState === prevEditorState
    ) {
      deadKeyState = { phase: 'after-dead', editorState: view.state }
      return true
    }
    if (
      deadKeyState?.phase === 'after-dead' &&
      deadKeyState?.editorState === prevEditorState
    ) {
      deadKeyState = null
      return true
    }
    deadKeyState = null
    return false
  }

  let eventHandlers = View.EditorView.domEventHandlers({
    keydown(ev, view) {
      if (
        ev.key === 'Shift' ||
        ev.key === 'Control' ||
        ev.key === 'Alt' ||
        ev.key === 'Meta'
      )
        return
      if (skipDueToDeadKey(ev, view)) return
      if (inputState == null && ev.key === '\\') {
        ev.preventDefault()
        scheduleExpecting(view.state)
      } else if (inputState != null && inputState.editorState === view.state) {
        resetExpecting()
        let key = ev.key
        if (ev.shiftKey) key = key.toUpperCase()
        let glyph = keymap.get(key)
        if (glyph == null) return
        ev.preventDefault()
        document.execCommand('insertText', false, glyph.glyph)
      }
    },
  })

  return [updateListener, eventHandlers, lifecycle]
}

export function highlight(highlight: HighlightStyle, textContent: string) {
  let nodes: HTMLElement[] = []
  let callback = (text: string, style: null | string): void => {
    let node = document.createElement('span')
    if (style) node.classList.add(style)
    node.textContent = text
    nodes.push(node)
  }
  let tree = language.parser.parse(textContent)
  let pos = 0
  Highlight.highlightTree(tree, highlight.match, (from, to, classes) => {
    if (from > pos) callback(textContent.slice(pos, from), null)
    callback(textContent.slice(from, to), classes)
    pos = to
  })
  pos != tree.length && callback(textContent.slice(pos, tree.length), null)
  return nodes
}

let glyphCompletionGlyph = (
  completion: Autocomplete.Completion,
  state: State.EditorState
) => {
  let isDarkTheme = state.facet(View.EditorView.darkTheme)
  let highlightStyle = isDarkTheme ? highlightDark : highlightLight
  const glyph = glyphsMap.get(completion.apply as string)
  if (glyph == null) return null
  let dom = document.createElement('div')
  dom.classList.add('cm-bqn-completion-glyph')
  dom.append(...highlight(highlightStyle, glyph.glyph as string))
  return dom
}

let glyphCompletionKey = (
  completion: Autocomplete.Completion,
  _state: State.EditorState
) => {
  const glyph = glyphsMap.get(completion.apply as string)
  if (glyph == null) return null
  let key = glyph.key != null ? `\\${glyph.key}` : `${glyph.glyph}`
  let dom = document.createElement('span')
  dom.classList.add('cm-bqn-completion-glyph-key')
  let inner = document.createElement('span')
  inner.classList.add('cm-bqn-completion-glyph-key-inner')
  inner.textContent = key
  dom.appendChild(inner)
  return dom
}

let glyphCompletions: Autocomplete.Completion[] = glyphs.map((glyph) => {
  return {
    label: `${glyph.title}`,
    apply: glyph.glyph,
  }
})

let glyphCompletion: Autocomplete.CompletionSource = (
  context: Autocomplete.CompletionContext
) => {
  if (context.matchBefore(/\u2022[A-Za-z\.]*/u) != null) return null
  let re = /[A-Za-z]*/
  let word = context.matchBefore(re)
  if (word == null || (word.from == word.to && !context.explicit)) return null
  return {
    from: word.from,
    filter: true,
    options: glyphCompletions,
    span: re,
  }
}

type ValueType =
  | 'array'
  | 'number'
  | 'character'
  | 'function'
  | '1-modifier'
  | '2-modifier'
  | 'namespace'

type SysItem = { name: string; type: ValueType }
type ListSys = (
  ns: string | null,
  state: State.EditorState
) => Promise<SysItem[]>

export let sysCompletion =
  (listSys: ListSys): Autocomplete.CompletionSource =>
  async (context: Autocomplete.CompletionContext) => {
    let word = context.matchBefore(/\u2022[A-Za-z0-9_\.]*/u)
    if (word == null || (word.from == word.to && !context.explicit)) return null
    let ns: string | null = word.text.replace(/\.[A-Za-z0-9_]*$/, '')
    if (ns === word.text) ns = null
    let items = await listSys(ns, context.state)
    let span =
      ns == null
        ? /\u2022[A-Za-z0-9_]*/u
        : new RegExp(escapeRegex(ns) + '.[A-Za-z0-9_]*', 'u')
    return {
      from: word.from,
      filter: true,
      options: items.map(formatSysItem),
      span,
    }
  }

function escapeRegex(v: string) {
  return v.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
}

function formatSysItem(item: SysItem) {
  switch (item.type) {
    case 'function':
      let name = item.name.replace(
        /\.([^\.]+)$/,
        (_, name) => '.' + name[0].toUpperCase() + name.slice(1)
      )
      return { label: '•' + name }
    default:
      return { label: '•' + item.name }
  }
}

/**
 * Configure extension for BQN.
 */
export function bqn(cfg: { sysCompletion?: ListSys } = {}) {
  let completions = [glyphCompletion]
  if (cfg.sysCompletion != null)
    completions.unshift(sysCompletion(cfg.sysCompletion))
  let extensions: State.Extension[] = [
    glyphInputMethod(),
    highlightLight,
    highlightDark,
    Autocomplete.autocompletion({
      override: completions,
      activateOnTyping: false,
      addToOptions: [
        {
          render: glyphCompletionGlyph,
          position: 5,
        },
        {
          render: glyphCompletionKey,
          position: 90,
        },
      ],
    }),
  ]
  return new LanguageSupport(language, extensions)
}
