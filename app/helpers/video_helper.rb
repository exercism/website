module VideoHelper
  def video_embed(type, id)
    if type == :vimeo
      vimeo_embed(id)
    else
      youtube_embed(id)
    end
  end

  def youtube_embed(id)
    src = "https://www.youtube-nocookie.com/embed/#{id}"
    tag.div class: 'c-youtube-container' do
      tag.iframe(width: "560", height: "315", src:, frameborder: "0",
        allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture", allowfullscreen: true)
    end
  end

  def vimeo_embed(id)
    src = "https://player.vimeo.com/video/#{id}&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479&transparent=0"
    tag.div class: 'c-youtube-container' do
      tag.iframe(width: "560", height: "315", src:, frameborder: "0",
        allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture", allowfullscreen: true) +
        javascript_include_tag("https://player.vimeo.com/api/player.js")
    end
  end
end
