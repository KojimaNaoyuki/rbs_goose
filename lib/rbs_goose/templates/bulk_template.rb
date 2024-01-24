# frozen_string_literal: true

require 'langchain'

module RbsGoose
  module Templates
    class BulkTemplate
      def initialize(instruction:, examples:)
        @template = Langchain::Prompt::FewShotPromptTemplate.new(
          prefix: instruction,
          suffix: "#{input_template_string}\n",
          example_prompt: example_prompt,
          examples: [bulk_examples(examples)],
          input_variables: %w[typed_ruby_list]
        )
      end

      def format(typed_ruby_list)
        template.format(typed_ruby_list: typed_ruby_list.join("\n"))
      end

      def parse_result(result)
        [IO::File.from_markdown(result)]
      end

      private

      attr_reader :template

      def example_prompt
        Langchain::Prompt::PromptTemplate.new(
          template: "#{input_template_string}\n{refined_rbs_list}",
          input_variables: %w[typed_ruby_list refined_rbs_list]
        )
      end

      def input_template_string
        "========Input========\n{typed_ruby_list}\n\n========Output========"
      end

      def bulk_examples(examples)
        {
          typed_ruby_list: examples.map(&:typed_ruby).join("\n"),
          refined_rbs_list: examples.map(&:refined_rbs).join("\n")
        }
      end
    end
  end
end