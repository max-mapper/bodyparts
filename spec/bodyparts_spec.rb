require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BodyParts" do
  
  [TMail::Mail, Mail].each do |mail_object|
    it "should accept and parse #{mail_object} objects as input" do
      generic = FakeMessage.fake_emails[:generic]
      message = FakeMessage.new_mail(mail_object, generic[:headers])
      BodyParts.find_reply_in(message)[:new_message].should == generic[:reply_text]
    end
  end

  %w(gmail yahoo hotmail aol_webmail generic).each do |mail_server|
    it "should strip out the replies from a #{mail_server} message containing forwarded junk" do
      mail_server = FakeMessage.fake_emails[mail_server.to_sym]
      message = FakeMessage.new_mail(Mail, mail_server[:headers])
      BodyParts.find_reply_in(message.to_s)[:new_message].should == mail_server[:reply_text]
    end
  end
  
  it "should always use the first reply delimiter in a message containing multiple replies" do
    multiple_replies = FakeMessage.fake_emails[:multiple_replies]
    message = FakeMessage.new_mail(Mail, multiple_replies[:headers])
    BodyParts.find_reply_in(message.to_s)[:new_message].should == multiple_replies[:reply_text]
  end
  
  it "should return the rest of the thread" do
    generic = FakeMessage.fake_emails[:generic]
    message = FakeMessage.new_mail(Mail, generic[:headers])
    BodyParts.find_reply_in(message.to_s).should == {:new_message => generic[:reply_text], :rest_of_thread => generic[:rest_of_thread].gsub("\n", "\r\n").strip}
  end
  
  it "should return the entire message as a new message if there isn't a reply" do
    no_reply = FakeMessage.fake_emails[:no_reply]
    message = FakeMessage.new_mail(Mail, no_reply[:headers])
    BodyParts.find_reply_in(message.to_s)[:new_message].should == no_reply[:reply_text]
  end
  
  it "should correctly parse the body from messages that contain attachments" do
    with_attachment = FakeMessage.fake_emails[:with_attachment]
    message = FakeMessage.load_mail(with_attachment[:filename])
    BodyParts.find_reply_in(message)[:new_message].should == with_attachment[:reply_text]
  end
end