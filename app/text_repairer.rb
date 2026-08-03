class TextRepairer
  MOJIBAKE_SIGNATURE = /Ã|Â|â€/.freeze

  def self.repair(text)
    return text unless text.match?(MOJIBAKE_SIGNATURE)

    repaired = text.encode('Windows-1252').force_encoding('UTF-8')
    repaired.valid_encoding? ? repaired : text
  rescue Encoding::UndefinedConversionError
    text
  end
end
