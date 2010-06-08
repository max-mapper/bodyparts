require 'mail'

class BodyParts
  def self.find_reply_in(email)
    email = Mail::Message.new(email) unless email.class == Mail::Message
    message_id = email.message_id
    x_mailer = email['x-mailer']

    rules = [
      { :server => 'Gmail',
        :reply_delimiter => /^On.*?wrote:.$/m
      },
      { :server => 'Yahoo! Mail',
        :reply_delimiter => /^_+\r\nFrom:/
      },
      { :server => 'Microsoft Live Mail/Hotmail',
        :reply_delimiter =>  /\r\n\r\n(Date|Subject):/
      },
      { :server => 'Outlook Express/AOL Webmail',
        :reply_delimiter =>  /^-+.*Original Message.*-+/
      }
    ]

    if email.multipart?
      body = email.parts.first.body.raw_source
    else
      body = email.body.raw_source
    end
    
    matches = []
    rules.each {|rule| matches << body.match(rule[:reply_delimiter])}
    matches.compact!
    match = matches.sort_by {|m| m.begin(0)}.first
    new_message = body[0, match.begin(0)]
    {:new_message => new_message.strip, :rest_of_thread => body[match.begin(0)..-1].strip}
  end
end