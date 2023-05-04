import { Theme } from '../ThemePreferenceForm'

export const THEMES: Theme[] = [
  {
    label: 'Light',
    value: 'light',
    background: 'white',
    iconFilter: 'textColor1NoDark',
  },
  {
    label: 'System',
    value: 'system',
    background:
      'linear-gradient(135deg, rgba(255,255,255,1) 50%, rgba(48,43,66,1) 50%)',
    iconFilter: 'gray',
  },
  {
    label: 'Dark',
    value: 'dark',
    background: '#302b42', //russianViolet
    iconFilter: 'aliceBlue',
  },
  {
    label: 'Accessibility Dark',
    value: 'accessibility-dark',
    background: 'black',
    iconFilter: 'whiteNoDark',
  },
]
