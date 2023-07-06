# frozen_string_literal: true

module Gitt
  module Parsers
    # Parses trailer to produce a person.
    class Person
      def initialize email_start: "<", email_end: ">", model: Models::Person
        @email_start = email_start
        @email_end = email_end
        @model = model
      end

      def call content
        if content.start_with? email_start
          model[email: content.delete_prefix(email_start).delete_suffix(email_end)]
        else
          name, email = content.split " #{email_start}"
          email.delete_suffix! email_end if email

          model[name:, email:]
        end
      end

      private

      attr_reader :email_start, :email_end, :model
    end
  end
end
