require 'socket'
require 'runit-man/service_info'
require 'runit-man/partials'
require 'sinatra/content_for'

module Helpers
  include Rack::Utils
  include Sinatra::Partials
  include Sinatra::ContentFor
  alias_method :h, :escape_html

  attr_accessor :even_or_odd_state

  def host_name
    unless @host_name
      begin
        @host_name = Socket.gethostbyname(Socket.gethostname).first
      rescue
        @host_name = Socket.gethostname
      end
    end
    @host_name
  end

  def service_infos
    ServiceInfo.all
  end

  def service_action(name, action, label)
    partial :service_action, :locals => {
      :name   => name,
      :action => action,
      :label  => label
    }
  end

  def log_link(name, options = {})
    count = (options[:count] || 100).to_i
    title = options[:title].to_s || count
    blank = options[:blank] || false
    hint  = options[:hint].to_s  || ''
    hint  = " title=\"#{h(hint)}\"" unless hint.empty?
    blank = blank ? ' target="_blank"' : ''
    "<a#{hint}#{blank} href=\"/#{h(name)}/log#{ (count != 100) ? "/#{count}" : '' }#footer\">#{h(title)}</a>"
  end

  def even_or_odd
    self.even_or_odd_state = !even_or_odd_state
    even_or_odd_state
  end

  def stat_subst(s)
    s.split(/\s/).map do |s|
      if s =~ /(\w+)/ && t.runit.services.table.subst[$1].translated?
        s.sub(/\w+/, t.runit.services.table.subst[$1].to_s)
      else
        s
      end
    end.join(' ')
  end
end
