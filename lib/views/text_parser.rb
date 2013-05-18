class TextParser
  def initialize(text)
    @text = text
  end

  def paragraphs
    @paragraphs ||= @text.split("\n\n")
  end

  def split_in_length(width)
    blobs = [""]

    if @text.start_with?("> ")
      prefix = "> "
      @text = @text[2..-1]
    else
      prefix = ""
    end

    @text.to_s.split(" ").each do |word|
      if blobs.last.length + word.length >= width - prefix.length
        blobs << word
      else
        blobs.last << " #{word}"
      end
    end

    blobs.map{|x| "#{prefix}#{x.strip}"}
  end
end
