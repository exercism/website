import { createTheme } from '@uiw/codemirror-themes'
import { tags as t } from '@lezer/highlight'
import { EDITOR_COLORS } from '../../JikiscriptExercisePage/CodeMirror/extensions/create-theme/colorScheme'

export const htmlTheme = createTheme({
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
      tag: t.special(t.brace),
      color: '#0080FF',
      fontWeight: '500',
    },
    {
      tag: t.name,
      color: '#7A009F',
    },
    {
      tag: t.content,
      color: '#00008B',
    },
    {
      tag: t.tagName,
      color: '#0080FF',
      fontWeight: '500',
      fontStyle: 'italic',
    },
    {
      tag: t.angleBracket,
      color: '#888',
    },
    {
      tag: t.attributeName,
      color: '#7A009F',
    },
    {
      tag: t.attributeValue,
      color: '#3E8A00',
    },

    // for JS stuff - we might not need this
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
    {
      tag: [t.definition(t.typeName), t.typeName],
      color: '#00008B',
    },
  ],
})
