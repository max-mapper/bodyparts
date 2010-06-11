require 'mail'
require 'tmail'

class BodyParts
  def self.rules
     [{ :server => 'Gmail', :reply_delimiter => /^On.*?wrote:.$/m },
      { :server => 'Yahoo! Mail', :reply_delimiter => /^_+\r\nFrom:/ },
      { :server => 'Microsoft Live Mail/Hotmail', :reply_delimiter =>  /\r\n\r\n(Date|Subject):/ },
      { :server => 'Outlook Express/AOL Webmail', :reply_delimiter =>  /^-+.*Original Message.*-+/ }]
  end
  
  def self.extract_tmail_attributes(tmail_object)
    message_id = tmail_object.message_id
    x_mailer = tmail_object['x-mailer'].to_s
    body = if tmail_object.multipart?
      tmail_object.parts.first.body
    else
      tmail_object.body
    end
    {:message_id => message_id, :x_mailer => x_mailer, :body => body}
  end
  
  def self.extract_mail_attributes(mail_object)
    message_id = mail_object['message_id']
    x_mailer = mail_object['x-mailer']

    if mail_object.multipart?
      body = mail_object.parts.first.body.raw_source
    else
      body = mail_object.body.raw_source
    end
    {:message_id => message_id, :x_mailer => x_mailer, :body => body}
  end
  
  def self.find_reply_in(email)
    email = Mail::Message.new(email) if email.is_a? String
    mail_attributes = case email.class.to_s
      when "TMail::Mail" then extract_tmail_attributes(email)
      when "Mail::Message" then extract_mail_attributes(email)
      else raise "You must pass in either a TMail or Mail object or raw email source text"
    end
    body = mail_attributes[:body]
    matches = rules.map {|rule| body.match(rule[:reply_delimiter])}.compact!
    unless matches.empty?
      match = matches.sort_by {|m| m.begin(0)}.first
      new_message = body[0, match.begin(0)]
      {:new_message => new_message.strip, :rest_of_thread => body[match.begin(0)..-1].strip}
    else
      {:new_message => body, :rest_of_thread => nil}
    end
  end
end