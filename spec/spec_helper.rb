require 'spec'
require File.expand_path(File.dirname(__FILE__) + '/../lib/bodyparts.rb')


class FakeMessage
  def self.fake_emails
    YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/emails.yml'))
  end
  
  def self.default_mail_headers
    { "body" => "I would like to let you know that the special fabric softener that you emailed to my postbox was quite nice",
      "from" => "flubs@gebarchnik.com",
      "to" => "donkeytron@wizzled.biz",
      "message_id" => "<abc45566@revetonkatruck.local.tmail>",
      "date" => "Wed, 23 Sep 2009 09:11:23 -0700"
    }
  end

  def self.new_mail(custom_headers={})
    headers = default_mail_headers.merge(custom_headers)
    mail = Mail.new do
      text_part do
        body headers.delete("body")
      end
    end
    headers.each {|header, content| mail[header] = content }
    mail
  end
end