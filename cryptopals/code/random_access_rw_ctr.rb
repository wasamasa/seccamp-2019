require 'base64'
require 'openssl'

def b64decode(string)
  Base64.decode64(string).bytes
end

def str(bytes)
  bytes.pack('C*')
end

def random_bytes(size)
  (0...size).map { rand(256) }
end

def xor_buffers(a, b)
  result = Array.new(a.length)
  a.each_index { |i| result[i] = a[i] ^ b[i] }
  result
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

PLAINTEXT = b64decode('RXMgdHJvbW1lbHRlbiBkaWUgU2NoZWxsd2FsZQptaXQgS3JhZnQgYXVmIGVpbmVyIFdlbGxzY2hhbGUuClp1c2FtbWVuIG1pdCBkZXIgV2Fsc2NoZWxsZQpnYWIgZGllcyBkaWUgc2Nob2Vuc3RlIFNjaGFsbHdlbGxlLgo=')
KEY = random_bytes(16)
NONCE = random_bytes(16)
CIPHERTEXT = aes_ctr_encrypt(PLAINTEXT, KEY, NONCE)

def edit_internal(ciphertext, key, nonce, offset, newtext)
  decrypted = aes_ctr_decrypt(ciphertext, key, nonce)
  newtext.each_with_index { |byte, i| decrypted[offset + i] = byte }
  aes_ctr_encrypt(decrypted, key, nonce)
end

def edit(ciphertext, offset, newtext)
  edit_internal(ciphertext, KEY, NONCE, offset, newtext)
end

def efficient_solution(ciphertext)
  random_message = random_bytes(ciphertext.length)
  edited_message = edit(ciphertext, 0, random_message)
  puts str(xor_buffers(xor_buffers(ciphertext, edited_message), random_message))
end

def guess_byte(ciphertext, offset)
  (0..127).each do |byte|
    return byte if ciphertext == edit(ciphertext, offset, [byte])
  end
  raise "couldn't guess byte"
end

def slow_solution(ciphertext)
  ciphertext.size.times { |i| print guess_byte(ciphertext, i).chr }
end

efficient_solution(CIPHERTEXT)
# slow_solution(CIPHERTEXT)
