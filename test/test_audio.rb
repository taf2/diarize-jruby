# diarize-jruby
# 
# Copyright (c) 2013 British Broadcasting Corporation
# 
# Licensed under the GNU Affero General Public License version 3 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.gnu.org/licenses/agpl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'helper'
require 'mocha/setup'
require 'ostruct'

class TestAudio < Test::Unit::TestCase

  def setup
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    @audio = Diarize::Audio.new audio_uri
  end

  def test_initialize_file_uri
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    audio = Diarize::Audio.new audio_uri
    assert_equal audio.uri, audio_uri
    assert_equal audio.path, File.join(File.dirname(__FILE__), 'data', 'foo.wav')
  end

  def test_initialize_http_uri
    hash = Digest::MD5.hexdigest('http://example.com/test.wav')
    Kernel.expects(:system).with("wget http://example.com/test.wav -O /tmp/#{hash}").returns(true)
    File.expects(:new).with('/tmp/' + hash).returns(true)
    audio_uri = URI('http://example.com/test.wav')
    audio = Diarize::Audio.new audio_uri
    assert_equal audio.path, '/tmp/' + hash 
  end

  def test_clean_local_file
    audio_uri = URI('file:' + File.join(File.dirname(__FILE__), 'data', 'foo.wav'))
    audio = Diarize::Audio.new audio_uri
    File.expects(:delete).never
    audio.clean!
  end

  def test_clean_http_file
    hash = Digest::MD5.hexdigest('http://example.com/test.wav')
    Kernel.expects(:system).with("wget http://example.com/test.wav -O /tmp/#{hash}").returns(true)
    File.expects(:new).with('/tmp/' + hash).returns(true)
    audio_uri = URI('http://example.com/test.wav')
    audio = Diarize::Audio.new audio_uri
    File.expects(:delete).with('/tmp/' + hash).returns(true)
    audio.clean!
  end

  def test_segments_raises_exception_when_audio_is_not_analysed
    assert_raise Exception do
      @audio.segments
    end
  end

  def test_analyze
    # TODO - We don't test the full ESTER2 algorithm for now
  end

  def test_segments
    @audio.instance_variable_set('@segments', [1, 2, 3])    
    assert_equal @audio.segments, [1, 2, 3]
  end

  def test_speakers_is_cached
    @audio.instance_variable_set('@speakers', [1, 2, 3])
    assert_equal @audio.speakers, [1, 2, 3]
  end

  def test_speakers
    segment1 = OpenStruct.new({ :speaker => 's1' })
    segment2 = OpenStruct.new({ :speaker => 's2' })
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ]) 
    assert_equal @audio.speakers, ['s1', 's2']
  end

  def test_segments_by_speaker
    segment1 = OpenStruct.new({ :speaker => 's1' })
    segment2 = OpenStruct.new({ :speaker => 's2' })
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.segments_by_speaker('s1'), [ segment1, segment1 ]
    assert_equal @audio.segments_by_speaker('s2'), [ segment2 ]
  end

  def test_duration_by_speaker
    segment1 = OpenStruct.new({ :speaker => 's1', :duration => 2})
    segment2 = OpenStruct.new({ :speaker => 's2', :duration => 3})
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.duration_by_speaker('s1'), 4
    assert_equal @audio.duration_by_speaker('s2'), 3
  end

  def test_top_speakers
    segment1 = OpenStruct.new({ :speaker => 's1', :duration => 2})
    segment2 = OpenStruct.new({ :speaker => 's2', :duration => 3})
    @audio.instance_variable_set('@segments', [ segment1, segment2, segment1 ])
    assert_equal @audio.top_speakers, ['s1', 's2']
  end

  def test_set_uri_and_type_uri
    @audio.uri = 'foo'
    @audio.type_uri = 'bar'
    assert_equal @audio.uri, 'foo'
    assert_equal @audio.type_uri, 'bar'
  end

  def test_show
    assert_equal @audio.show, 'foo'
  end

end
