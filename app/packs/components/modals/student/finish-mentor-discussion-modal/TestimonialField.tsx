import React, { ChangeEvent } from 'react'

export const TestimonialField = ({
  id,
  min,
  max,
  value,
  onChange,
}: {
  id: string
  min: number
  max: number
  value: string
  onChange: (e: ChangeEvent) => void
}): JSX.Element => {
  return (
    <>
      <textarea
        value={value}
        onChange={onChange}
        id={id}
        placeholder="Write your testimonial here"
        minLength={min}
        maxLength={max}
      />
      <div className="counter">
        <div>
          {value.length} / {max}
        </div>
        <div>{min} minimum</div>
      </div>
    </>
  )
}
