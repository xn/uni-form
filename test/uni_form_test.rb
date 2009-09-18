require File.dirname(__FILE__) + '/../../../../config/environment'
require File.dirname(__FILE__) + '/../lib/uni_form'

require 'test/unit'
require 'rubygems'
require 'action_controller/assertions/dom_assertions'
require 'action_view/test_case'

User = Struct.new("User", :id, :first_name, :last_name, :email, :likes_dogs, :likes_cats, :sex)

class UniFormTest < ActionView::TestCase # Test::Unit::TestCase
  tests UniForm::UniFormHelper

  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::CaptureHelper
  include ActionController::Assertions::DomAssertions
  
  alias_method :original_assert_dom_equal, :assert_dom_equal
  
  # had to add this to get the tests to run with rails 2.0, maybe a better way?
  def protect_against_forgery?
  end
  
  def setup
    @user = User.new
    
    @user.id = 45
    @user.first_name = "Marcus"
    @user.last_name = "Irven"
    @user.email = "marcus@example.com"
    @user.likes_dogs = true
    @user.likes_cats = true
    @user.sex = "M"
    
    def @user.errors() 
      Class.new do
        def on(field) 
          nil
        end 
      end.new 
    end
    
    @controller = Class.new do
      def url_for(options, *parameters_for_method_reference)
        "http://www.example.com"
      end
    end.new

    self.output_buffer = ''
  end

  def test_pass
    assert_equal 1, 1
  end
        
  def test_empty_form

    uni_form_for(:user, @user) do |f|
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm"></form>
    html
  
    assert_dom_equal expected, output_buffer
  end

  def test_default_fieldset
  
    uni_form_for(:user, @user) do |f|
      f.fieldset do
      end
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <fieldset class="blockLabels">
        </fieldset>
      </form>
    html
  
    assert_dom_equal expected, output_buffer
  end

  def test_inline_fieldset
  
    uni_form_for(:user, @user) do |f|
      f.fieldset :type => "inline" do
      end
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <fieldset class="inlineLabels">
        </fieldset>
      </form>
    html
  
    assert_dom_equal expected, output_buffer

    self.output_buffer = ''

    uni_form_for(:user, @user) do |f|
      f.fieldset :type => :inline do
      end
    end

    assert_dom_equal expected, output_buffer
  end
  
  def test_fieldset_with_legend
  
    uni_form_for(:user, @user) do |f|
      f.fieldset :legend => "User" do
      end
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <fieldset class="blockLabels">
          <legend>User</legend>
        </fieldset>
      </form>
    html
  
    assert_dom_equal expected, output_buffer
  end
  
  def test_block_fieldset
  
    uni_form_for(:user, @user) do |f|
      f.fieldset :type => "block" do
      end
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <fieldset class="blockLabels">
        </fieldset>
      </form>
    html
  
    assert_dom_equal expected, output_buffer
  end
  
  def test_submit
  
    uni_form_for(:user, @user) do |f|
      output_buffer.concat f.submit("save")
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <div class="buttonHolder">
          <button type="submit" name="commit" class="submitButton">save</button>
        </div>
      </form>
    html
  
    assert_dom_equal expected, output_buffer
  end
  
  # def test_label_for
  #   puts label_for('post', 'category', 'text' => 'This Category')
  # end
  
  def test_text_field
  
    uni_form_for(:user, @user) do |f|
      f.fieldset do
        f.text_field(:first_name)
      end
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <fieldset class="blockLabels">
          <div class="ctrlHolder">
            <label for="user_first_name">First name</label>
            <input name="user[first_name]" size="30" type="text" class="textInput" id="user_first_name" value="Marcus"/>
          </div>
        </fieldset>
      </form>
    html
  
    assert_dom_equal expected, output_buffer
  end

  def test_text_field_with_label
    uni_form_for(:user, @user) do |f|
      f.fieldset do
        f.text_field(:first_name, :label => "First")
      end
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <fieldset class="blockLabels">
          <div class="ctrlHolder">
            <label for="user_first_name">First</label>
            <input name="user[first_name]" size="30" type="text" class="textInput" id="user_first_name" value="Marcus"/>
          </div>
        </fieldset>
      </form>
    html
  
    assert_dom_equal expected, output_buffer
  end
  
  def test_required_text_field
  
    uni_form_for(:user, @user) do |f|
      f.fieldset do
        f.text_field(:first_name, :required => true)
      end
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <fieldset class="blockLabels">
          <div class="ctrlHolder">
            <label for="user_first_name"><em>*</em> First name</label>
            <input name="user[first_name]" size="30" type="text" class="textInput" id="user_first_name" value="Marcus"/>
          </div>
        </fieldset>
      </form>
    html
  
    assert_dom_equal expected, output_buffer
  end
  
  def test_non_required_text_field

    uni_form_for(:user, @user) do |f|
      f.fieldset do
        f.text_field(:first_name, :required => false)
      end
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <fieldset class="blockLabels">
          <div class="ctrlHolder">
            <label for="user_first_name">First name</label>
            <input name="user[first_name]" size="30" type="text" class="textInput" id="user_first_name" value="Marcus"/>
          </div>
        </fieldset>
      </form>
    html
  
    assert_dom_equal expected, output_buffer
  end
  
  def test_text_field_with_hint
  
    uni_form_for(:user, @user) do |f|
      f.fieldset do
        f.text_field(:first_name, :hint => "Your given name")
      end
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <fieldset class="blockLabels">
          <div class="ctrlHolder">
            <label for="user_first_name">First name</label>
            <input name="user[first_name]" size="30" type="text" class="textInput" id="user_first_name" value="Marcus"/>
            <p class="formHint">Your given name</p>
          </div>
        </fieldset>
      </form>
    html
    
    assert_dom_equal expected, output_buffer
  end
  
  def test_hidden_field
    uni_form_for(:user, @user) do |f|
      output_buffer.concat f.hidden_field(:id)
    end
    
    expected = <<-html
      <form action="http://www.example.com" method="post" class="uniForm">
        <input type="hidden" id="user_id" name="user[id]" value="45"/>
      </form>
    html
    
    assert_dom_equal expected, output_buffer
  end
   
  # #Whats up with class="", also look at label
  # def test_check_box
  #   _erbout = ''
  # 
  #   uni_form_for(:user, @user) do |f|
  #     _erbout.concat f.check_box(:likes_dogs)
  #   end
  #   
  #   expected = <<-html
  #     <form action="http://www.example.com" method="post" class="uniForm">
  #         <div class="ctrlHolder">
  #           <label class="inlineLabel" for="user_likes_dogs">Likes dogs</label>
  #           <input name="user[likes_dogs]" type="checkbox" id="user_likes_dogs" value="1" class="" checked="checked"/>
  #           <input name="user[likes_dogs]" type="hidden" value=\"0\" />
  #         </div>
  #     </form>
  #   html
  #   
  #   assert_dom_equal expected, _erbout
  # end

  def test_radio_buttons

    uni_form_for(:user, @user) do |f|
      f.ctrl_group :label => 'Sex', :hint => 'Pex!' do
        output_buffer.concat f.radio_button(:sex, "Male", :label => 'Maaan', :checked => 'checked')
        output_buffer.concat f.radio_button(:sex, "Female", :label => 'Wooman')
      end
    end

    expected = <<-html
     <form action="http://www.example.com" method="post" class="uniForm">
         <div class="ctrlHolder">
           <p class="label">Sex</p>
           <div class="multiField">
             <label class="blockLabel" for="user_sex_male">
               <input name="user[sex]" type="radio" id="user_sex_male" value="Male" checked="checked"/>Maaan</label>
             <label class="blockLabel" for="user_sex_female">
               <input name="user[sex]" type="radio" id="user_sex_female" value="Female" />Wooman</label>
           </div>
           <p class="formHint">Pex!</p>
         </div>
     </form>
    html

    assert_dom_equal expected, output_buffer
  end
  
  
  
  private
  
  def assert_dom_equal(expected, actual, message="")    
    # We remove whitespace between elements and at the begining and end of expected
    original_assert_dom_equal expected.gsub(/>\s+</, "><").strip, actual, message
  end
end
