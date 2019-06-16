require 'openssl'
require 'zlib'

def str(bytes)
  bytes.pack('C*')
end

def random_bytes(size, limit = 256)
  (0...size).map { rand(limit) }
end

def aes_ctr_encrypt(buffer, key, nonce)
  cipher = OpenSSL::Cipher.new('AES-128-CTR')
  cipher.encrypt
  cipher.key = str(key)
  cipher.iv = str(nonce)
  result = cipher.update(str(buffer)) + cipher.final
  result.bytes
end

alias aes_ctr_decrypt aes_ctr_encrypt

SESSIONID = '447520626973742042756464686973742e'

def format_request(input)
  "POST / HTTP/1.1
Host: example.com
Cookie: sessionid=#{SESSIONID}
Content-Length: #{input.length}
#{input}
"
end

def compress(string)
  Zlib::Deflate.deflate(string)
end

def oracle(input)
  key = random_bytes(16)
  nonce = random_bytes(16)
  payload = compress(format_request(input))
  aes_ctr_encrypt(payload.bytes, key, nonce).size
end

$last_length = nil

def report_progress(string)
  print " #{' ' * $last_length}\r" if $last_length
  print " #{string}\r"
  $last_length = string.length
end

CHARSET = '0123456789abcdef'

def ctr_guess_byte(known)
  guesses = {}
  suffix = random_bytes(10, (128..255))
  CHARSET.each_byte do |byte|
    input = "sessionid=#{str(known + [byte] + suffix)}"
    guesses[byte] = oracle(input)
  end
  guesses.minmax_by { |_, v| v }
end

def ctr_guess_bytes
  known = []
  loop do
    min, max = ctr_guess_byte(known)
    if min[1] == max[1]
      if known.length >= 32
        return known
      else
        known = []
        redo
      end
    end
    known << min[0]
    report_progress(str(known))
  end
end

puts " #{SESSIONID}"
ctr_guess_bytes
puts
