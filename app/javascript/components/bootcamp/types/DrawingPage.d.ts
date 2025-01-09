declare type DrawingPageProps = {
  drawing: {
    uuid: string
    title: string
  }
  code: {
    code: string
    storedAt: string
  }
  links: {
    updateCode: string
    drawingsIndex: string
  }
}
