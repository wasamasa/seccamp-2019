def hexdecode(string)
  [string].pack('H*').bytes
end

def str(bytes)
  bytes.pack('C*')
end

ENGLISH_HISTOGRAM = { ' ' => 0.14,
                      'e' => 0.12,
                      't' => 0.09,
                      :other => 0.09,
                      'a' => 0.08,
                      'o' => 0.07,
                      'i' => 0.06,
                      'n' => 0.06,
                      's' => 0.06,
                      'h' => 0.06,
                      'r' => 0.05,
                      'd' => 0.04,
                      'l' => 0.04,
                      'c' => 0.02,
                      'u' => 0.02,
                      'm' => 0.02,
                      'w' => 0.02,
                      'f' => 0.02,
                      'g' => 0.02,
                      'y' => 0.01,
                      'p' => 0.01,
                      'b' => 0.01,
                      'v' => 0.01,
                      'k' => 0.01,
                      'j' => 0.01,
                      'x' => 0.00,
                      'q' => 0.00,
                      'z' => 0.00 }

def frequencies(string)
  result = Hash.new { |h, k| h[k] = 0 }
  total = string.length
  string.each_char { |char| result[char] += 1 }
  result.each { |k, v| result[k] = v.to_f / total }
  result
end

def chi_squared(hist1, hist2)
  score = 0
  hist1.each do |k, v1|
    v2 = hist2[k] || 0
    next if v1.zero?
    score += (v1 - v2)**2 / v1
  end
  score
end

def english_score(string)
  return 0 unless string.ascii_only?
  input = string.downcase.tr('^ a-z', '.')
  histogram = frequencies(input)
  histogram[:other] = histogram['.'] || 0
  histogram.delete('.')
  score = 1 / chi_squared(ENGLISH_HISTOGRAM, histogram)
  score *= 2 if histogram[:other] < 0.05
  score
end

def xor_buffer_with_byte(buffer, byte)
  result = Array.new(buffer.size)
  result.each_index { |i| result[i] = buffer[i] ^ byte }
  result
end

CIPHERTEXT = hexdecode('49662074686572652077617320612070726f626c656d20796f2049276c6c20736f6c7665206974')
best_score = 0
best_solution = ''

(0..255).each do |key|
  solution = str(xor_buffer_with_byte(CIPHERTEXT, key))
  score = english_score(solution)
  if score > best_score
    best_score = score
    best_solution = solution
  end
end

puts "score: #{best_score}"
puts best_solution
