declare type DrawingPageProps = {
  drawing: {
    uuid: string
  }
  code: {
    code: string
    stored_at: string
  }
  links: {
    update_code: string
    drawings_index: string
  }
}
