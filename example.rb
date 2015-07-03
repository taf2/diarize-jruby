require File.join(File.dirname(__FILE__), 'lib', 'diarize')

if ARGV.size < 1
  $stderr.puts "usage: jruby example.rb http://example.com/file.wav"
  exit 1
end

audio = Diarize::Audio.new ARGV[0]
audio.analyze!
audio.segments
audio.speakers
audio.to_rdf
speakers = audio.speakers
speakers.first.gender
speakers.first.model.mean_log_likelihood
speakers.first.model.components.size
