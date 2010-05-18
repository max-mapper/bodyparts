require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BodyParts" do
  
  it "should strip out the replies from a message containing forwarded junk" do
    bp = BodyParts.new
    message = FakeMessage.new(:gmail_single_reply)
    bp.find_reply_in(message.raw_email).should == message.reply_text
  end
  
end