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
    if mail_encoding = tmail_object['content_transfer_encoding']
      content_encoding = mail_encoding.to_s.downcase
    else
      content_encoding = "not known"
    end
    
    body = if tmail_object.multipart?
      tmail_object.parts.first.body
    else
      tmail_object.body
    end
    
    {:content_encoding => content_encoding, :body => body}
  end
  
  def self.extract_mail_attributes(mail_object)
    if plain_part = mail_object.find_first_mime_type('text/plain')
      part = plain_part
    else
      part = mail_object
    end
    
    if mail_encoding = part['content_transfer_encoding'] || mail_encoding = mail_object['content_transfer_encoding']
      content_encoding = mail_encoding.encoding
    else
      content_encoding = "not known"
    end

    {:content_encoding => content_encoding, :body => part.body.raw_source}
  end
  
  def self.find_reply_in(email)
    email = Mail::Message.new(email) if email.is_a? String
    
    mail_attributes = case email.class.to_s
      when "TMail::Mail" then extract_tmail_attributes(email)
      when "Mail::Message" then extract_mail_attributes(email)
      else raise "You must pass in either a TMail or Mail object or raw email source text"
    end
    
    raw_body = mail_attributes[:body]
    body = case mail_attributes[:content_encoding]
      when "base64" then Base64.decode64 raw_body
      when "quoted-printable" then Mail::Encodings::QuotedPrintable.decode raw_body
      else raw_body
    end

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