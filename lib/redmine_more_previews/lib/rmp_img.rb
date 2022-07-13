# encoding: utf-8
# frozen_string_literal: true

# Redmine plugin to preview various file types in redmine's preview pane
#
# Copyright © 2018 -2022 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

module RedmineMorePreviews
  module Lib
    module RmpImg
      class << self
        
        def to_img(markup, format="PNG")
        
          Rails.logger.warn('rmagick_font_path option is deprecated. Use minimagick_font_path instead.') \
            unless Redmine::Configuration['rmagick_font_path'].nil?
          font_path = Redmine::Configuration['minimagick_font_path'].presence || Redmine::Configuration['rmagick_font_path'].presence
          
          width  =800
          height =1220
          
          img = MiniMagick::Image.create(".#{format}", false)
          MiniMagick::Tool::Convert.new do |gc|
          
            # size / background
            gc.size('%dx%d' % [width, height])
            #gc.xc('white')
            gc.background('lightblue')
            
            # font
            gc.font(font_path) if font_path.present?
            gc.font('Arial')
            
            # Hello World
            gc.pointsize(12)
            gc.stroke('transparent')
            gc.fill('black')
            gc.strokewidth(1)
            text = Redmine::Utils::Shell.shell_quote(markup)
            gc << "pango:#{markup}"
            
            gc << img.path
          end
          
          img.to_blob
        ensure
          img.destroy! if img
        end if Object.const_defined?(:MiniMagick)
        
      end #class
    end #module
  end #module
end #module
