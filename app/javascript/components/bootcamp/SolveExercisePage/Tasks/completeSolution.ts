export async function completeSolution(url: string): Promise<{
  next_exercise: NextExercise
  next_level_idx: number
  completed_level_idx: number
}> {
  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: null,
  })

  if (!response.ok) {
    throw new Error('Failed to complete solution')
  }

  return response.json()
}

export type NextExercise = {
  slug: string
  title: string
  description: string
  project: {
    slug: string
    title: string
    description: string
  }
  solve_url: string
}

// example
// {
//   "slug": "manual-solve",
//   "title": "Manually solve a maze",
//   "description": "Manually solve a maze",
//   "project": {
//       "slug": "maze",
//       "title": "Maze",
//       "description": "Use then implement a basic maze"
//   }
// }
