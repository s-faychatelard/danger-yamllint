module Danger
  # Lint Yaml files inside your projects.
  # This is done using the [YamLint](https://github.com/adrienverge/yamllint) tool.
  # Results are passed out as a table in markdown.
  #
  # @example Specifying custom config file.
  #
  #          yamllint.lint
  #
  # @see  s-faychatelard/danger-yamllint
  # @tags yaml
  #
  class DangerYamllint < Plugin
    # Lints Swift files. Will fail if `swiftlint` cannot be installed correctly.
    # Generates a `markdown` list of warnings for the prose in a corpus of
    # .markdown and .md files.
    #
    # @param   [Boolean] fail_on_error
    #          Generates CI failure on errors.
    # @param   [Boolean] inline_mode
    #          Create inlined messages within the PR.
    # @return  [void]
    #
    def lint(fail_on_error: true, inline_mode: false)
      unless yamllint_exists?
        fail("Couldn't find yamllint command. Please install it first.")
      end

      results = parse(`yamllint -f parsable .`)
      return if results.empty?

      if inline_mode
        send_inline_comments(results, fail_on_error)
      else
        send_markdown_comment(results, fail_on_error)
      end
    end

    private

    def send_markdown_comment(results, fail_on_error)
      if fail_on_error
        fail "YamlLint found issues:", sticky: false
      else
        warn "YamlLint found issues:", sticky: false
      end
      message = "### Resources\n\n"
      results[:all].each do |res|
        icon = res[:type] == :warning ? "⚠️" : "🛑"
        message << "- #{icon} **#{res[:message].capitalize}** at #{res[:file]}:#{res[:line]}:#{res[:character]} **(#{res[:rule]})**\n"
      end
      markdown message
    end

    def send_inline_comments(results, fail_on_error)
      results[:warnings].each do |res|
        warn(res[:message], file: res[:file], line: res[:line])
      end
      results[:errors].each do |res|
        if fail_on_error
          fail(res[:message], file: res[:file], line: res[:line])
        else
          warn(res[:message], file: res[:file], line: res[:line])
        end
      end
    end

    def parse(results)
      parsed = {
        warnings: [],
        errors: [],
        all: []
      }
      results.each_line do |line|
        line.gsub!(/(.*):(.*):(.*): \[(.*)\](.*)\((.*)\)$/) do
          match = Regexp.last_match
          type = match[4].strip == "warning" ? :warning : :error
          obj = {
            file: match[1].strip,
            line: match[2].strip,
            type: type,
            character: match[3].strip,
            rule: match[6].strip,
            message: match[5].strip
          }
          parsed[type == :warning ? :warnings : :errors].push(obj)
          parsed[:all].push(obj)
        end
      end
      return parsed
    end

    def yamllint_exists?
      system "which yamllint > /dev/null 2>&1"
    end
  end
end
