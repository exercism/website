class CreateStreamingEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :streaming_events do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.string :youtube_id, null: true
      t.boolean :featured, null: false, default: false
      t.string :thumbnail_url, null: true

      t.index [:starts_at, :ends_at]

      t.timestamps
    end
  end
end

=begin 

{
  "Jeremie Gillet (Gleam live coding)" => DateTime.new(2023,2,9,13,0),
  "Theo Harris (Gleam live coding)" => DateTime.new(2023,2,11,0,0),
  "Aage ten Hengel (F# live coding)" => DateTime.new(2023,2,6,13,15),
  "Sergey Kuznetsov (Elixir live coding)" => DateTime.new(2023,2,18,13,0),
}.each do |title, date|
  StreamingEvent.create!(title: title, starts_at: date, ends_at: date + 90.minutes, description: "")
end

StreamingEvent.create!(
  title: "Interview & AMA with José Valim",
  description: "Jeremy speaks to José Valim, the Creator of Elixir, about why he chose to make Elixir functional.",
  starts_at: DateTime.new(2023,2,9,16,30),
  ends_at: DateTime.new(2023,2,9,18,00),
  youtube_id: "LknqlTouTKg",
  thumbnail_url: "https://assets.exercism.org/images/thumbnails/yt-jose-interview-preview.jpg",
  featured: true
)

StreamingEvent.create!(
  title: "Interview & AMA with Louis Pilfold",
  description: "Jeremy speaks to Louis Pilfold, the Creator of Gleam, about why he chose to make Gleam functional.",
  starts_at: DateTime.new(2023,2,21,18,30),
  ends_at: DateTime.new(2023,2,9,20,00),
  featured: true
  # youtube_id: "LknqlTouTKg",
  # thumbnail_url: "https://assets.exercism.org/images/thumbnails/yt-jose-interview-preview.jpg"
)

=end
