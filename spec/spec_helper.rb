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
  
  def self.load_mail(name)
    Mail::Message.new(File.read(File.expand_path(File.dirname(__FILE__) + "/#{name}.eml")))
  end

  def self.new_mail(mail_class, custom_headers={})
    headers = default_mail_headers.merge(custom_headers)
    
    mail = mail_class.new do
      if mail_class == Mail
        text_part do
          body headers.delete("body")
        end
      end
    end
    
    if mail_class == TMail::Mail
      %w(body from to).each do |attr|
        mail.send "#{attr}=", headers[attr]
        headers.delete attr
      end
    end
    
    headers.each {|header, content| mail[header] = content }
    mail
  end
end