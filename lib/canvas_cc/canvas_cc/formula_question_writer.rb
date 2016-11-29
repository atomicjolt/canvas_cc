module CanvasCc::CanvasCC
  class FormulaQuestionWriter < QuestionWriter

    register_writer_type 'formula_question'

    private

    def self.write_responses(presentation_node, question)
      presentation_node.response_str(:rcardinality => 'Single', :ident => 'response1') do |response_node|
        response_node.render_fib do |render_node|
          render_node.response_label(:ident => 'answer1', :rshuffle => 'No')
        end
      end
    end

    def self.write_response_conditions(processing_node, question)
      processing_node.respcondition(:continue => 'No') do |condition|
        condition.conditionvar do |var_node|
          var_node.other
        end
      end
    end

    def self.write_additional_nodes(item_node, question)
      write_standard_answer_feedbacks(item_node, question)
    end
  end
end
