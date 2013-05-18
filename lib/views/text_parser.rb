class TextParser
  def initialize(text)
    @text = text
  end

  def paragraphs
    @paragraphs ||= @text.split("\n\n")
  end

  def split_in_length(width)
    blobs = [""]

    @text.to_s.split(" ").each do |word|
      if blobs.last.length + word.length >= width
        blobs << word
      else
        blobs.last << " #{word}"
      end
    end

    blobs.map(&:strip)
  end
end
