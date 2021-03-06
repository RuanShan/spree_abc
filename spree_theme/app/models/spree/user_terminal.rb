module Spree

  # compatible query media for a template_theme
  class UserTerminal < ActiveRecord::Base
    attr_accessor :is_preview, :is_mobile, :is_weixin
    attr_accessor :os, :platform #UserAgent.attribute

    scope :cellphone, ->{ where( name: 'Cellphone' ) }
    scope :pc, ->{ where( name: 'PC' ) }

    def is_mobile
      name == 'Cellphone'
    end

    def to_json
      {name: name, is_mobile: is_mobile, is_preview: is_preview, is_weixin: is_weixin }.to_json
    end

  end

end
