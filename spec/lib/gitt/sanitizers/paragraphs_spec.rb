# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Sanitizers::Paragraphs do
  subject(:sanitizer) { described_class.new }

  describe "#call" do
    it "answers paragraphs split by double new lines" do
      expect(sanitizer.call("one\n\ntwo")).to eq(%w[one two])
    end

    it "answers paragraphs with no trailing new line" do
      expect(sanitizer.call("one\n\ntwo\n")).to eq(%w[one two])
    end

    it "answers ASCII Doc listing block with single lines" do
      content = <<~CONTENT
        ----
        One.
        ----
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ----
            One.
            ----
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc listing block with spaced lines" do
      content = <<~CONTENT
        ----
        One.

        Two.
        ----
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ----
            One.

            Two.
            ----
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc code block with single lines" do
      content = <<~CONTENT
        [source,bash]
        ----
        git pull
        ----
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            [source,bash]
            ----
            git pull
            ----
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc code block with spaced lines" do
      content = <<~CONTENT
        [source,bash]
        ----
        git pull

        git status
        ----
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            [source,bash]
            ----
            git pull

            git status
            ----
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc code block with ID" do
      content = <<~CONTENT
        [#example,bash]
        ----
        git pull
        ----
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            [#example,bash]
            ----
            git pull
            ----
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc code block with line numbers" do
      content = <<~CONTENT
        [%linenums,bash]
        ----
        git pull
        ----
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            [%linenums,bash]
            ----
            git pull
            ----
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc code block with line numbers and highlights" do
      content = <<~CONTENT
        [%linenums,bash,highlight=1]
        ----
        git pull
        ----
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            [%linenums,bash,highlight=1]
            ----
            git pull
            ----
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc code block between lines" do
      content = <<~CONTENT
        Example:
        [source,bash]
        ----
        git pull

        git status
        ----
        End.
      CONTENT

      code = <<~CONTENT.strip
        [source,bash]
        ----
        git pull

        git status
        ----
      CONTENT

      expect(sanitizer.call(content)).to eq(["Example:", code, "End."])
    end

    it "answers ASCII Doc collapsible block with single lines" do
      content = <<~CONTENT
        [%collapsible]
        ====
        One.
        ====
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            [%collapsible]
            ====
            One.
            ====
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc collapsible block with spaced lines" do
      content = <<~CONTENT
        [%collapsible]
        ====
        One.

        Two.
        ====
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            [%collapsible]
            ====
            One.

            Two.
            ====
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc collapsible block that is open" do
      content = <<~CONTENT
        [%collapsible%open]
        ====
        One.

        Two.
        ====
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            [%collapsible%open]
            ====
            One.

            Two.
            ====
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc collapsible block with title" do
      content = <<~CONTENT
        .An Example
        [%collapsible]
        ====
        One.

        Two.
        ====
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            .An Example
            [%collapsible]
            ====
            One.

            Two.
            ====
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc literal block with single lines" do
      content = <<~CONTENT
        ....
        An example.
        ....
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ....
            An example.
            ....
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc literal block with spaced lines" do
      content = <<~CONTENT
        ....
        One.

        Two.
        ....
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ....
            One.

            Two.
            ....
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc passthrough block with single lines" do
      content = <<~CONTENT
        ++++
        An example.
        ++++
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ++++
            An example.
            ++++
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc passthrough block with spaced lines" do
      content = <<~CONTENT
        ++++
        One.

        Two.
        ++++
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ++++
            One.

            Two.
            ++++
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc quote block with single lines" do
      content = <<~CONTENT
        ____
        An example.
        ____
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ____
            An example.
            ____
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc quote block with spaced lines" do
      content = <<~CONTENT
        ____
        One.

        Two.
        ____
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ____
            One.

            Two.
            ____
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc sidebar block with single lines" do
      content = <<~CONTENT
        ****
        An example.
        ****
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ****
            An example.
            ****
          CONTENT
        ]
      )
    end

    it "answers ASCII Doc sidebar block with spaced lines" do
      content = <<~CONTENT
        ****
        One.

        Two.
        ****
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ****
            One.

            Two.
            ****
          CONTENT
        ]
      )
    end

    it "answers Markdown code block with single lines" do
      content = <<~CONTENT
        ```
        git pull
        ```
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ```
            git pull
            ```
          CONTENT
        ]
      )
    end

    it "answers Markdown code block with language" do
      content = <<~CONTENT
        ``` ruby
        1 + 1
        ```
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ``` ruby
            1 + 1
            ```
          CONTENT
        ]
      )
    end

    it "answers Markdown code block with spaced lines" do
      content = <<~CONTENT
        ```
        git pull

        git status
        ```
      CONTENT

      expect(sanitizer.call(content)).to eq(
        [
          <<~CONTENT.strip
            ```
            git pull

            git status
            ```
          CONTENT
        ]
      )
    end

    it "answers Markdown code block between lines" do
      content = <<~CONTENT
        Example:
        ```
        git pull

        git status
        ```
        End.
      CONTENT

      code = <<~CONTENT.strip
        ```
        git pull

        git status
        ```
      CONTENT

      expect(sanitizer.call(content)).to eq(["Example:", code, "End."])
    end

    it "answer empty array when nil" do
      expect(sanitizer.call(nil)).to eq([])
    end
  end
end
