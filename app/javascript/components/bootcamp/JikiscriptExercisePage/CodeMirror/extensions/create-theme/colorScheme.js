import { tags as t } from '@lezer/highlight'
import createTheme from './create-theme.js'
// uses createTheme by Chris Kempson

export const EDITOR_COLORS = {
  background: '#FFFFFF',
  foreground: '#4D4D4C',
  caret: '#AEAFAD',
  gutterBackground: '#FFFFFF',
  gutterForeground: '#4D4D4C80',
  lineHighlight: '#D6ECFA80',
  selection: '#D5D1F2',
  selectionMatch: '#D5D1F2',
}

// this is unused from now, but let's keep this as reference
// this contains the OG jikiscript colours, while the js-theme file may change.
export const colorScheme = createTheme({
  variant: 'light',
  settings: EDITOR_COLORS,
  styles: [
    {
      tag: [t.comment, t.lineComment],
      color: '#818B94',
      fontStyle: 'italic',
    },
    {
      tag: t.string,
      color: '#3E8A00',
    },
    {
      tag: t.controlKeyword,
      color: '#0080FF',
      fontWeight: '500',
    },
    {
      tag: t.definitionKeyword,
      color: '#0080FF',
      fontWeight: '500',
    },
    {
      tag: t.keyword,
      color: '#0080FF',
      fontWeight: '500',
    },
    {
      tag: [t.paren],
      color: '#888',
    },
    {
      tag: [t.bool, t.number, t.float],
      color: '#F33636',
    },
    {
      tag: [
        t.logicOperator,
        t.arithmeticOperator,
        t.operator,
        t.compareOperator,
      ],
      color: '#0080FF',
    },
    {
      tag: t.variableName,
      color: '#7A009F',
    },
    {
      tag: t.function(t.variableName),
      color: 'rgb(184, 0, 255)',
      borderBottom: '0.5px solid rgba(184, 0, 255, 0.6)',
    },
    {
      tag: t.className,
      color: '#00008B',
    },
  ],
})
