import React from 'react'
import { TestimonialsList } from '../profile'

export default function Testimonials({ data }: { data: any }): JSX.Element {
  return (
    <div>
      <h2 className="text-h1 text-center">
        87,305 people testified to the impact Exercism has had on their
        learning.
      </h2>

      {/* <TestimonialsList data = {data can come here} /> */}
    </div>
  )
}
