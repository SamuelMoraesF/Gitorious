# encoding: utf-8
#--
#   Copyright (C) 2013 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
class StandbyModeCommand
  def initialize(public_path, authorized_keys_path = nil,
                 global_hooks_path = RepositoryRoot.expand(".hooks"))
    @public_path = public_path
    @authorized_keys_path = authorized_keys_path
    @global_hooks_path = global_hooks_path
  end

  private

  attr_reader :public_path, :authorized_keys_path, :global_hooks_path

  def standby_file_path
    File.join(public_path, 'standby.html')
  end

  def standby_symlink_path
    File.join(public_path, 'system', 'standby.html')
  end
end
