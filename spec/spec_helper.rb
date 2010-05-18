require 'spec'
require 'ruby-debug'
require File.expand_path(File.dirname(__FILE__) + '/../lib/bodyparts.rb')

class FakeMessage
  attr_accessor :raw_email, :reply_text
  def initialize(type)
    emails = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/emails.yml'))
    if emails[type]
      @raw_email = emails[type][:raw_text]
      @reply_text = emails[type][:reply_text]
    else
      raise "No emails found for the type: #{type}, dummy!"
    end
  end
  
  def email
    Mail::Message.new(self.raw_email)
  end
end