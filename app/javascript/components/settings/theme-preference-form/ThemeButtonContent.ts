import { Theme } from '../ThemePreferenceForm'

export const THEMES: Theme[] = [
  {
    label: 'Light',
    value: 'light',
    background: 'white',
    icon: 'exercism-face-gradient',
  },
  {
    label: 'Dark',
    value: 'dark',
    background: '#302b42', //russianViolet
    icon: 'exercism-face-light',
  },
  {
    label: 'System',
    value: 'system',
    background:
      'linear-gradient(90deg, rgba(255,255,255,1) 50%, rgba(48,43,66,1) 50%)',
    icon: 'exercism-face-two-tone',
  },
  // {
  //  label: 'Accessibility Dark',
  //  value: 'accessibility-dark',
  //  background: 'black',
  //  iconFilter: 'whiteNoDark',
  // },
]
