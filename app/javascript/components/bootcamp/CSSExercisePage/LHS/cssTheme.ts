import { createTheme } from '@uiw/codemirror-themes'
import { tags as t } from '@lezer/highlight'

export const cssTheme = createTheme({
  theme: 'light',
  settings: {
    // background: '#ffffff',
    // backgroundImage: '',
    // foreground: '#75baff',
    // caret: '#5d00ff',
    // selection: '#036dd626',
    // selectionMatch: '#036dd626',
    // lineHighlight: '#8a91991a',
    // gutterBorder: '1px solid #ffffff10',
    // gutterBackground: '#fff',
    // gutterForeground: '#8a919966',
  },
  styles: [
    { tag: t.comment, color: '#888888' },
    { tag: t.definition(t.className), color: '#cc00cc' },
    { tag: t.propertyName, color: '#ff5500' },
    { tag: t.number, color: '#aa5500' },
    { tag: t.unit, color: '#0077aa' },
    { tag: t.string, color: '#008800' },
    { tag: t.color, color: '#0000ff' },
    { tag: t.keyword, color: '#cc0000' },
    { tag: t.operator, color: '#6600cc' },
    { tag: t.punctuation, color: '#aaaaaa' },
  ],
})
