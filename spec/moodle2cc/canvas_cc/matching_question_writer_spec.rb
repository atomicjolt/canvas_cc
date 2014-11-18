require 'spec_helper'

module CanvasCc::CanvasCC
  describe MatchingQuestionWriter do

    let(:question) { CanvasCc::CanvasCC::Models::Question.create('matching_question')}

    it 'creates the question item xml for a matching question' do
      question.identifier = 9001
      question.title = 'its over nine thousannnd'
      question.general_feedback = 'ur totes awesome'
      question.material = 'this is a question, or is it?'
      question.distractors = %w(distractor1 distractor2)

      match1 = {:id => '1', :question_text => 'qtext', :question_text_format => '1', :answer_text => 'answer1', :answer_feedback => 'good'}
      match2 = {:id => '2', :question_text => 'qtext2', :question_text_format => '1', :answer_text => 'answer2', :answer_feedback => 'bad'}
      question.matches = [match1, match2]

      xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |node|
        QuestionWriter.write_question(node, question)
      end.doc

      expect(xml.at_xpath('item/@ident').value).to eq question.identifier.to_s
      expect(xml.at_xpath('item/@title').value).to eq question.title
      expect(xml.at_xpath("item/itemmetadata/qtimetadata/qtimetadatafield[fieldlabel=\"question_type\" and fieldentry=\"#{question.question_type}\"]")).to_not be_nil

      response = xml.at_xpath("item/presentation/response_lid[@ident=\"response_#{match1[:id]}\"]")
      expect(response.at_xpath('material/mattext[@texttype="text/plain"]').text).to eq match1[:question_text]
      expect(response.at_xpath("render_choice/response_label[@ident=\"#{match1[:id]}\"]/material/mattext").text).to eq match1[:answer_text]
      expect(response.at_xpath("render_choice/response_label[@ident=\"#{match2[:id]}\"]/material/mattext").text).to eq match2[:answer_text]
      expect(response.at_xpath("render_choice/response_label[@ident=\"#{Digest::MD5.hexdigest(question.distractors[0])}\"]/material/mattext").text).to eq question.distractors[0]
      expect(response.at_xpath("render_choice/response_label[@ident=\"#{Digest::MD5.hexdigest(question.distractors[1])}\"]/material/mattext").text).to eq question.distractors[1]

      response = xml.at_xpath("item/presentation/response_lid[@ident=\"response_#{match2[:id]}\"]")
      expect(response.at_xpath('material/mattext[@texttype="text/plain"]').text).to eq match2[:question_text]
      expect(response.at_xpath("render_choice/response_label[@ident=\"#{match1[:id]}\"]/material/mattext").text).to eq match1[:answer_text]
      expect(response.at_xpath("render_choice/response_label[@ident=\"#{match2[:id]}\"]/material/mattext").text).to eq match2[:answer_text]
      expect(response.at_xpath("render_choice/response_label[@ident=\"#{Digest::MD5.hexdigest(question.distractors[0])}\"]/material/mattext").text).to eq question.distractors[0]
      expect(response.at_xpath("render_choice/response_label[@ident=\"#{Digest::MD5.hexdigest(question.distractors[1])}\"]/material/mattext").text).to eq question.distractors[1]

      condition = xml.at_xpath("item/resprocessing/respcondition/conditionvar[varequal=\"#{match1[:id]}\"]/..")
      expect(condition.at_xpath("conditionvar/varequal[@respident=\"response_#{match1[:id]}\"]")).not_to be_nil
      set_var = condition.at_xpath('setvar')
      expect(set_var.attributes['varname'].value).to eq 'SCORE'
      expect(set_var.attributes['action'].value).to eq 'Add'
      expect(set_var.text).to eq '50.00'

      condition = xml.at_xpath("item/resprocessing/respcondition/conditionvar/not[varequal=\"#{match1[:id]}\"]/..")
      expect(condition.at_xpath("not/varequal[@respident=\"response_#{match1[:id]}\"]")).not_to be_nil
      expect(condition.at_xpath("not/varequal[@respident=\"response_#{match1[:id]}\"]").text).to eq("1")

      condition = xml.at_xpath("item/resprocessing/respcondition/conditionvar[varequal=\"#{match2[:id]}\"]/..")
      expect(condition.at_xpath("conditionvar/varequal[@respident=\"response_#{match2[:id]}\"]")).not_to be_nil
      set_var = condition.at_xpath('setvar')
      expect(set_var.attributes['varname'].value).to eq 'SCORE'
      expect(set_var.attributes['action'].value).to eq 'Add'
      expect(set_var.text).to eq '50.00'

      feedback = xml.at_xpath("item/itemfeedback[@ident=\"#{match1[:id]}_fb\"]/flow_mat/material/mattext[@texttype=\"text/plain\"]")
      expect(feedback.text).to eq match1[:answer_feedback]
      feedback = xml.at_xpath("item/itemfeedback[@ident=\"#{match2[:id]}_fb\"]/flow_mat/material/mattext[@texttype=\"text/plain\"]")
      expect(feedback.text).to eq match2[:answer_feedback]
    end
  end
end
