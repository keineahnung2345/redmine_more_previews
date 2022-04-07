# encoding: utf-8
#
# RedmineMorePreviews converter to preview office files with LibreOffice
#
# Copyright © 2020 Stephan Wenzel <stephan.wenzel@drwpatent.de>
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

class Libre < RedmineMorePreviews::Conversion

  #---------------------------------------------------------------------------------
  # constants
  #---------------------------------------------------------------------------------
  LIBRE_OFFICE_BIN = 'soffice'.freeze
  
  #---------------------------------------------------------------------------------
  # check: is LibreOffice available?
  #---------------------------------------------------------------------------------
  def status
    s = run [LIBRE_OFFICE_BIN, "--version"]
    [:text_libre_office_available, s[2] == 0 ]
  end

  def darken(source, fname)
    # dark background of powerpoint will be white after conversion
    if source.ends_with? "ppt" or source.ends_with? "pptx"
      file = File.open(fname)
      file_data = file.read; nil
      file.close

      file_data_out = file_data.dup
      indices = file_data.enum_for(:scan, /color:#[0-9a-f]+/).map do
        id = Regexp.last_match.offset(0).first+7
        red = file_data[id...id+2].to_i(16)
        green = file_data[id+2...id+4].to_i(16)
        blue = file_data[id+4...id+6].to_i(16)
        if red > 127 and green > 127 and blue > 127
          file_data_out[id...id+6] = (red/2).to_s(16).rjust(2, "0") + (green/2).to_s(16).rjust(2, "0") + (blue/2).to_s(16).rjust(2, "0")
        end
      end

      File.open(fname, "w") {
        |f| f.write file_data_out
      }
    end
  end
  
  def convert
  
    Dir.mktmpdir do |tdir| 
    user_installation = File.join(tdir, "user_installation")
    command(cd + join + soffice( source, user_installation ))
    darken(source, cd.split(' ')[1][1...-1] + thisdir(outfile)[1...])
    command(cd + join + move(thisdir(outfile)))
    end
    
  end #def
  
  def soffice( src, user_installation )
    if Redmine::Platform.mswin?
    "#{LIBRE_OFFICE_BIN} --headless --convert-to #{preview_format} --outdir #{shell_quote tmpdir} #{shell_quote src}"
    else
    "#{LIBRE_OFFICE_BIN} --headless --convert-to #{preview_format} --outdir #{shell_quote tmpdir} -env:UserInstallation=file://#{user_installation} #{shell_quote src}"
    end
  end #def
  
end #class