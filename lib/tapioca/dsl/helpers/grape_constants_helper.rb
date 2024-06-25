# typed: strict
# frozen_string_literal: true

module Tapioca
  module Dsl
    module Helpers
      module GrapeConstantsHelper
        extend T::Sig

        CallbacksMethodsModuleName = "GeneratedCallbacksMethods"
        RequestResponseMethodsModuleName = "GeneratedRequestResponseMethods"
        RoutingMethodsModuleName = "GeneratedRoutingMethods"

        APIInstanceClassName = "PrivateAPIInstance"
        EndpointClassName = "PrivateEndpoint"
      end
    end
  end
end
