import React from 'react'

type LearningCountry = {
  country: string
  flag: string
  percent: number
}

export function TopLearningCountries({
  data,
}: {
  data: LearningCountry[]
}): JSX.Element {
  return (
    <div>
      <h6 className="text-h6 mb-8">Top learning countries</h6>
      <div className="flex flex-wrap gap-8">
        {data.map((i) => (
          <LearningCountryTag key={i.country} country={i} />
        ))}
      </div>
    </div>
  )
}

function LearningCountryTag({ country }: { country: LearningCountry }) {
  return (
    <div className="shadow-sm text-h6 flex flex-row items-center py-4 px-12 !w-fit rounded-16">
      <span className="mr-10">{country.flag}</span>
      {country.country}{' '}
      <span className="font-normal font-mono text-13 ml-10">
        {country.percent}%
      </span>
    </div>
  )
}
