# # frozen_string_literal: true
# require "inflecto"
# # require_relative "persistence"
# module ZenWallet
#   module Introspections
#     module TableFinder
#       module ClassMethods
#         def table(some = nil)
#           arg = some || self
#           name = case arg
#                  when Class then arg.name
#                  when Persistence::Store, HD::Chainable then arg.class.name
#                  else String(arg)
#                  end
#           i = Inflecto
#           i.underscore(i.pluralize(i.demodulize(name))).to_sym
#         end
#       end
#
#       def self.included(sub)
#         puts sub
#         sub.extend(ClassMethods)
#       end
#
#       def table(name = nil)
#         self.class.table(name)
#       end
#     end
#
#     module StoreFinder
#       include TableFinder
#
#       module ClassMethods
#         include TableFinder::ClassMethods
#         def store(container, some = nil)
#           name = some || self.name
#           container.resolve("store.#{table(name)}")
#         end
#       end
#       attr_reader :container
#
#       def self.included(sub)
#         sub.extend(ClassMethods)
#       end
#
#       def store(name = nil)
#         self.class.store(container, name)
#       end
#     end
#   end
# end
