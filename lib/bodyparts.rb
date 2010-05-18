require 'mail'

class BodyParts
  def find_reply_in(email)
    email = Mail::Message.new(email) unless email.class == Mail::Message
    message_id = email.message_id
    debugger
    x_mailer = email['x-mailer']
    
    rules = [
      { :server => 'Gmail', 
        :identifier => lambda { message_id =~ /gmail/}, 
        :reply_delimiter => /^.*#{@from_name}\s+<#{@from_address}>\s*wrote:.*$/ 
      },
      { :server => 'Yahoo! Mail', 
        :identifier => lambda { message_id =~ /.+yahoo\.com>\z/}, 
        :reply_delimiter => /^_+\nFrom: #{@from_name} <#{@from_address}>$/ 
      },
      { :server => 'Microsoft Live Mail/Hotmail', 
        :identifier => lambda { email['return-path'] =~ /<.+@(hotmail|live).com>/}, 
        :reply_delimiter =>  /^Date:.+\nSubject:.+\nFrom: #{@from_address}$/ 
      },
      { :server => 'Outlook Express', 
        :identifier => lambda { x_mailer =~ /Microsoft Outlook Express/ }, 
        :reply_delimiter =>  /^----- Original Message -----$/
      },
      { :server =>  'Outlook', 
        :identifier => lambda { x_mailer =~ /Microsoft Office Outlook/ }, 
        :reply_delimiter => /^\s*_+\s*\nFrom: #{@from_name}.*$/ 
      },
      { :server => nil, 
        :identifier => lambda { true }, 
        :reply_delimiter =>  /^.*#{@from_address}.*$/ 
      }
    ]

    notes = email.body.to_s

    rules.find do |rule|
      if rule[:identifier].call
        reply_match = email.body.match(rule[:reply_delimiter])
        if reply_match
          notes = email.body[0, reply_match.begin(0)]
          source = rule[:server]
          next true
        end
      end
    end
    
    [notes.strip, source ||= nil]
  end
end