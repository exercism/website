import { createTheme } from '@uiw/codemirror-themes'
import { tags as t } from '@lezer/highlight'
import { EDITOR_COLORS } from '../../JikiscriptExercisePage/CodeMirror/extensions/create-theme/colorScheme'

export const cssTheme = createTheme({
  theme: 'light',
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
      tag: [t.controlKeyword, t.definitionKeyword, t.keyword],
      color: '#0080FF',
      fontWeight: '500',
    },
    {
      tag: [t.paren, t.squareBracket, t.brace],
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
      color: '#b800ff',
    },
    {
      tag: t.className,
      color: '#00008B',
    },
    {
      tag: t.labelName,
      color: '#00008B',
    },
    {
      tag: t.propertyName,
      color: '#7A009F',
    },
    {
      tag: [t.tagName],
      color: '#00008B',
    },
    {
      tag: t.color,
      color: '#F33636',
    },
    // px, %, em (similar to numbers)
    {
      tag: t.unit,
      color: '#F33636',
    },
  ],
})
