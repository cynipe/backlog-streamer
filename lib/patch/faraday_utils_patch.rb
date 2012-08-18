# -*- encoding: utf-8 -*-

module Faraday
  module Utils
    ESCAPE_RE = /[^\w .~-]+/

    def escape(s)
      s.to_s.gsub(ESCAPE_RE) {
        '%' + $&.unpack('H2' * $&.bytesize).join('%').upcase
      }.tr(' ', '+')
    end
  end
end
