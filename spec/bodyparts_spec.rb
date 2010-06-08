require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BodyParts" do
  %w(gmail yahoo hotmail aol_webmail generic).each do |mail_server|
    it "should strip out the replies from a #{mail_server} message containing forwarded junk" do
      mail_server = FakeMessage.fake_emails[mail_server.to_sym]
      message = FakeMessage.new_mail(mail_server[:headers])
      BodyParts.find_reply_in(message.to_s)[:new_message].should == mail_server[:reply_text]
    end
  end
  
  it "should always use the first reply delimiter in a message containing multiple replies" do
    multiple_replies = FakeMessage.fake_emails[:multiple_replies]
    message = FakeMessage.new_mail(multiple_replies[:headers])
    BodyParts.find_reply_in(message.to_s)[:new_message].should == multiple_replies[:reply_text]
  end
  
  it "should return the rest of the thread" do
    generic = FakeMessage.fake_emails[:generic]
    message = FakeMessage.new_mail(generic[:headers])
    BodyParts.find_reply_in(message.to_s).should == {:new_message => generic[:reply_text], :rest_of_thread => generic[:rest_of_thread].gsub("\n", "\r\n").strip}
  end
end