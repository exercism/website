import React from 'react'
import { SingleSelect } from '../common/SingleSelect'
import { nameForLocale } from '@/utils/name-for-locale'
import { flagForLocale } from '@/utils/flag-for-locale'

type Links = { update: string }

export type LocalizationFormProps = {
  userLanguage: string
  supportedLanguages: string[]
  links: Links
}

const normalize = (loc: string) => loc.trim().toLowerCase().replace(/_/g, '-')

function buildLanguageOptions(
  userLanguage: string,
  supported: string[]
): string[] {
  const seen = new Set<string>()
  const out: string[] = []

  const push = (loc?: string) => {
    if (!loc) return
    const n = normalize(loc)
    if (!seen.has(n)) {
      seen.add(n)
      out.push(n)
    }
  }

  push(userLanguage)

  for (const loc of supported) push(loc)

  return out
}

function LanguageOption({ option }: { option: string }): JSX.Element {
  const flag = flagForLocale(option)
  const label = nameForLocale(option)
  return (
    <div className="flex items-center gap-8">
      {flag && <span aria-hidden="true">{flag}</span>}
      <span>{label}</span>
    </div>
  )
}

function LanguageSelect({
  value,
  setValue,
  options,
}: {
  value: string
  setValue: (value: string) => void
  options: string[]
}): JSX.Element {
  return (
    <SingleSelect<string>
      className="w-[250px]"
      options={options}
      value={normalize(value)}
      setValue={(v) => setValue(normalize(v))}
      SelectedComponent={LanguageOption}
      OptionComponent={LanguageOption}
    />
  )
}

export default function LocalizationForm({
  userLanguage,
  supportedLanguages,
  links,
}: LocalizationFormProps): JSX.Element {
  const [language, setLanguage] = React.useState(normalize(userLanguage))

  const options = React.useMemo(
    () => buildLanguageOptions(userLanguage, supportedLanguages),
    [userLanguage, supportedLanguages]
  )

  return (
    <div>
      <h2>Select your language preference</h2>
      <hr className="c-divider --small" />

      <div className="field mb-16">
        <label htmlFor="user_language" className="label">
          Language preference
        </label>

        <LanguageSelect
          value={language}
          setValue={setLanguage}
          options={options}
        />
      </div>

      <button
        onClick={() => {
          console.log('PATCH WITH', language, '→', links.update)
        }}
        className="btn btn-primary mt-4"
      >
        Save changes
      </button>
    </div>
  )
}
