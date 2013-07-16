require 'bundler/setup'
Bundler.require

class BudgetItem

  attr_reader :title
  attr_reader :note

  def initialize(atts)
    @title = atts.fetch(:summary)
    @note = atts.fetch(:description)
  end

  def price_in_local_currency
    @price_in_local_currency ||= note[/[£€]?\d+\S*[£€]?/]
  end

  def price_in_usd
    @price_in_usd ||=
      begin
        match = note[/x\$\S+/]
        match[2..-1] if match
      end
  end

  #def parse_note
    #/(?<local>)\s+x\$(?<usd>\d+\S+)/ =~ note
    #@price_in_local_currency = local
  #end

  def attributes
    @atts ||= {
      title:                    title,
      note:                     note,
      price_in_local_currency:  price_in_local_currency,
      price_in_usd:             price_in_usd,
    }
  end

end

events = Dir[__dir__ + '/*.ics'].flat_map do |path|
  file = File.open(path)
  ICS::Event.file(file)
end

events.sort_by(&:dtstart).each do |event|
  next unless event.attributes.has_key?(:description)

  item = BudgetItem.new(event.attributes)

  next unless item.price_in_local_currency
  next unless item.price_in_local_currency[/[£€]/]

  puts [
    item.title,
    nil,
    item.price_in_local_currency,
    nil,
    item.price_in_usd,
  ].join("\t")
end
