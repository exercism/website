import { createTheme } from '@uiw/codemirror-themes'
import { tags as t } from '@lezer/highlight'

export const htmlTheme = createTheme({
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
    { tag: t.comment, color: '#787b80' },
    { tag: t.string, color: '#000' },
    // braces inside strings
    { tag: t.special(t.brace), color: '#00aaff' },
    { tag: t.name, color: '#cc00cc' },
    // actual content that's inside brackets
    { tag: t.content, color: '#000' },
    { tag: t.tagName, color: '#ff5500' },
    { tag: t.angleBracket, color: '#ff0000' },
    { tag: t.attributeName, color: '#00aa00' },
    { tag: t.attributeValue, color: '#aa00aa' },

    // JS/TS stuff - we might not need these
    { tag: t.number, color: '#aa5500' },
    { tag: t.bool, color: '#0033aa' },
    { tag: t.keyword, color: '#cc0000' },
    { tag: t.operator, color: '#6600cc' },
    { tag: t.variableName, color: '#008800' },
    { tag: t.className, color: '#5500aa' },
    { tag: t.definition(t.typeName), color: '#aa0099' },
    { tag: t.typeName, color: '#990000' },
  ],
})
