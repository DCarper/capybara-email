class Capybara::Email::Driver < Capybara::Driver::Base
  attr_reader :email

  def initialize(email)
    @email = email
  end

  def follow(method, path, attributes = {})
    Capybara.current_session.driver.follow(method, path, attributes)
  end

  def body
    dom.to_xml
  end

  def subject
    email.subject
  end

  def to
    email.to
  end

  def from
    email.from
  end

  def dom
    @dom ||= Nokogiri::HTML(source)
  end

  def find(selector)
    dom.xpath(selector).map { |node| Capybara::Email::Node.new(self, node) }
  end

  def source
    if email.mime_type == 'text/plain'
      convert_to_html(raw)
    else
      raw
    end
  end

  def raw
    email.body.encoded
  end

  private

  def convert_to_html(text)
    "<html><body>#{convert_links(text)}</body></html>"
  end

  def convert_links(text)
    text.gsub(%r{(https?://\S+)}, %q{<a href="\1">\1</a>})
  end
end
