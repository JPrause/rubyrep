require File.dirname(__FILE__) + '/spec_helper.rb'

include RR

describe TypeCastingCursor do
  before(:each) do
    Initializer.configuration = standard_config
  end

  it "initialize should cache the provided cursor and the retrieved Column objects" do
    cursor = TypeCastingCursor.new Session.new.left, 'extender_type_check', :dummy_org_cursor
    cursor.columns['id'].name.should == 'id'
    cursor.columns['decimal'].name.should == 'decimal'
    cursor.org_cursor.should == :dummy_org_cursor
  end
  
  it "next_row should return the casted row, next? and clear should be delegated to the original cursor" do
    session = Session.new
    org_cursor = session.left.select_cursor("select id, decimal, timestamp, byteea from extender_type_check where id = 1")
    
    cursor = TypeCastingCursor.new session.left, 'extender_type_check', org_cursor
    cursor.next?.should be_true
    row = cursor.next_row
    cursor.next?.should be_false
    cursor.clear
    
    # verify that the row values has been converted to the correct type
    row['id'].should be_an_instance_of(Fixnum)
    row['timestamp'].should be_an_instance_of(Time)
    row['decimal'].should be_an_instance_of(BigDecimal)
    row['byteea'].should be_an_instance_of(String)
    
    # verify that the row values were converted correctly
    row.should == {
      'id' => 1, 
      'decimal' => BigDecimal.new("1.234"),
      'timestamp' => Time.local(2007,"nov",10,20,15,1),
      'byteea' => "dummy"
    }
  end
end