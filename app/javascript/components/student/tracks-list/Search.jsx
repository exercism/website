import React from 'react'

export function Search({ dispatch }) {
  function handleChange(e) {
    dispatch({
      type: 'criteria.changed',
      payload: { criteria: e.target.value },
    })
  }

  return (
    <input
      type="text"
      placeholder="Search language tracks"
      onChange={handleChange}
    />
  )
}
