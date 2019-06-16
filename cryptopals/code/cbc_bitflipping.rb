require 'openssl'

def str(bytes)
  bytes.pack('C*')
end

def random_bytes(size)
  (0...size).map { rand(256) }
end

def aes_cbc_internal(buffer, key, iv, mode)
  cipher = OpenSSL::Cipher.new('AES-128-CBC')
  cipher.send(mode)
  cipher.key = str(key)
  cipher.iv = str(iv)
  result = cipher.update(str(buffer)) + cipher.final
  result.bytes
end

def aes_cbc_encrypt(buffer, key, iv)
  aes_cbc_internal(buffer, key, iv, :encrypt)
end

def aes_cbc_decrypt(buffer, key, iv)
  aes_cbc_internal(buffer, key, iv, :decrypt)
end

KEY = random_bytes(16)
IV = random_bytes(16)
PLAINTEXT = 'comment=1234567890&uid=3'
CIPHERTEXT = aes_cbc_encrypt(PLAINTEXT.bytes, KEY, IV)

def decode_query_string(input)
  input.split('&')
       .map { |kv| kv.split('=') }
       .select { |kv| kv.length == 2}.to_h
end

def check(ciphertext)
  plaintext = str(aes_cbc_decrypt(ciphertext, KEY, IV))
  params = decode_query_string(plaintext)
  uid = params['uid']
  puts "checking #{plaintext.inspect}..."
  raise 'invalid string' unless uid
  uid.to_i
end

tampered_byte = '3'.ord ^ '0'.ord
tampered = CIPHERTEXT.clone
tampered[7] ^= tampered_byte

puts "regular UID: #{check(CIPHERTEXT)}"
puts "tampered UID: #{check(tampered)}"
