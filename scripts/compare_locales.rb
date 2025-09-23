require 'yaml'
require 'set'

def flatten_keys(hash, prefix = nil)
  hash.flat_map do |k, v|
    key = prefix ? "#{prefix}.#{k}" : k.to_s
    if v.is_a?(Hash)
      flatten_keys(v, key)
    else
      [key]
    end
  end
end

def compare_locale_files(file1, file2)
  yml1 = YAML.load_file(file1)
  yml2 = YAML.load_file(file2)

  lang1 = yml1.keys.first
  lang2 = yml2.keys.first

  keys1 = flatten_keys(yml1[lang1])
  keys2 = flatten_keys(yml2[lang2])

  set1 = Set.new(keys1)
  set2 = Set.new(keys2)

  missing_in_2 = set1 - set2
  missing_in_1 = set2 - set1

  puts "Keys in #{file1} but missing in #{file2}:"
  puts missing_in_2.to_a.sort
  puts
  puts "Keys in #{file2} but missing in #{file1}:"
  puts missing_in_1.to_a.sort
end

if ARGV.length != 2
  puts "Usage: ruby compare_locales.rb path/to/en.yml path/to/de.yml"
  exit 1
end

compare_locale_files(ARGV[0], ARGV[1])
