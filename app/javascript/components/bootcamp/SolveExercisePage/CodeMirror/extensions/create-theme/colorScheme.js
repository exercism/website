import { tags as t } from '@lezer/highlight'
import createTheme from './create-theme.js'
// uses createTheme by Chris Kempson
export const colorScheme = createTheme({
  variant: 'light',
  settings: {
    background: '#FFFFFF',
    foreground: '#4D4D4C',
    caret: '#AEAFAD',
    gutterBackground: '#FFFFFF',
    gutterForeground: '#4D4D4C80',
    lineHighlight: '#D6ECFA80',
    selection: '#D5D1F2',
    selectionMatch: '#D5D1F2',
  },
  styles: [
    {
      tag: t.comment,
      color: '#818B94',
      fontStyle: 'italic',
    },
    {
      tag: [t.variableName, t.propertyName, t.attributeName, t.regexp],
      color: '#019da4',
    },
    {
      tag: [t.paren, t.brace],
      color: '#8A99A6',
      fontWeight: 600,
    },
    {
      tag: [t.number, t.bool, t.null],
      color: 'green',
    },
    {
      tag: [t.className, t.typeName, t.definition(t.typeName)],
      color: '#C99E00',
    },
    {
      tag: [t.string, t.special(t.brace)],
      color: 'red',
    },
    {
      tag: t.operator,
      color: '#3E999F',
    },
    {
      tag: [t.definition(t.propertyName), t.function(t.variableName)],
      color: '#0081fc',
    },
    {
      tag: t.keyword,
      color: 'blue',
    },
    {
      tag: t.operatorKeyword,
      color: '#73abeb',
    },

    {
      tag: t.controlKeyword,
      color: '#A626A4',
      fontWeight: 500,
    },

    {
      tag: t.derefOperator,
      color: '#4D4D4C',
    },
  ],
})
