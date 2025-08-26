type Copy = {
  question: string
  choice: string
}

export const EXTERNAL_LANGUAGE_COPY: Record<string, Copy> = {
  en: {
    question: 'What language do you want to use the site in?',
    choice: 'In English 🇺🇸',
  },
  hu: {
    question: 'Milyen nyelven szeretnéd használni az oldalt?',
    choice: 'Magyarul 🇭🇺',
  },
  nl: {
    question: 'In welke taal wil je de site gebruiken?',
    choice: 'In het Nederlands 🇳🇱',
  },
  de: {
    question: 'In welcher Sprache möchtest du die Seite nutzen?',
    choice: 'Auf Deutsch 🇩🇪',
  },
  pt: {
    question: 'Em que língua queres usar o site?',
    choice: 'Em português 🇵🇹',
  },
  'pt-br': {
    question: 'Em que língua você quer usar o site?',
    choice: 'Em português do Brasil 🇧🇷',
  },
}
