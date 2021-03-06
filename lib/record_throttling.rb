# encoding: utf-8
#--
#   Copyright (C) 2012-2013 Gitorious AS
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
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

module RecordThrottling
  class LimitReachedError < StandardError; end

  def self.disable
    @@enabled = false
  end

  def self.enable
    @@enabled = true
  end

  def self.disabled?
    !@@enabled || !RecordThrottling::default_behavior
  end

  def self.reset_to_default
    @@enabled = RecordThrottling::default_behavior
  end

  def self.default_behavior
    Gitorious::Configuration.get("enable_record_throttling", true)
  end

  @@enabled = RecordThrottling::default_behavior

  def self.included(base)
    base.class_eval do
      include RecordThrottlingInstanceMethods

      # Thottles record creation/update.
      # Raises RecordThrottling::RecordThrottleLimitReachedError if limit is
      # reached.
      #
      # Options:
      # +:limit+ the amount of records allowed within (eg. 5)
      # +:timeframe+ the timeframe the limit should be within (eg. 5.minutes)
      # +:counter+ A proc returning the value to compare +:limit+ against
      # +:conditions+ A proc of the counts the last created_at query should use
      # Both the +:counter+ and +:conditions+ procs will receive the record
      # as argument.
      #
      # Example usage:
      # throttle_records :create, :limit => 5,
      #   :counter => proc{|record|
      #      record.user.projects.where("created_at > ?", 5.minutes.ago).count
      #   },
      #   :conditions => proc{|record| {:user_id => record.user.id} },
      #   :timeframe => 5.minutes
      def self.throttle_records(create_or_update, options)
        options.assert_valid_keys(:limit, :counter, :conditions, :timeframe, :actor)
        class_attribute :creation_throttle_options
        self.creation_throttle_options = options
        send("before_#{create_or_update}", :check_throttle_limits)
      end
    end
  end

  module RecordThrottlingInstanceMethods
    def check_throttle_limits
      options = self.class.creation_throttle_options
      scope = options[:scope] || self.class
      actor = options[:actor].call(self)
      raise LimitReachedError if !RecordThrottling.allowed?(scope, actor, options)
    end
  end

  def self.allowed?(scope, actor, options = {})
    return true if RecordThrottling.disabled?
    return true if options[:counter].call(actor) < options[:limit]
    cond = options[:conditions].call(actor)
    last_create = scope.maximum(:created_at, :conditions => cond)
    return true if !last_create || last_create < options[:timeframe].ago
    false
  end
end
