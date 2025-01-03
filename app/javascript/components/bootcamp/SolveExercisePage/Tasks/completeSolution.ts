export async function completeSolution(
  url: string
): Promise<{ next_exercise: NextExercise }> {
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
