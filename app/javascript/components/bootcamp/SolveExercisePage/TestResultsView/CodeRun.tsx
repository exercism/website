import React from 'react'
export function CodeRun({ codeRun }: { codeRun: string }) {
  if (!codeRun || codeRun.length === 0) return null
  return (
    <tr>
      <th>Code run:</th>
      <td>{codeRun}</td>
    </tr>
  )
}
