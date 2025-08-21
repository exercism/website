declare type DrawingPageProps = {
  drawing: {
    uuid: string
    title: string
    backgroundSlug: string
  }
  code: {
    code: string
    storedAt: string
  }
  backgrounds: Background[]
  links: {
    updateCode: string
    drawingsIndex: string
  }
}

type Background = {
  slug: string
  title: string
  imageUrl: string
}
