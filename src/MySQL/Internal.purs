module MySQL.Internal
  ( liftError
  ) where

import Prelude

import Effect.Aff (Aff)
import Effect.Exception (error)
import Control.Monad.Error.Class (throwError)
import Data.List.Types (NonEmptyList)
import Data.Newtype (unwrap)
import Data.NonEmpty (head)
import Foreign (ForeignError)

liftError :: forall a. NonEmptyList ForeignError -> Aff a
liftError = throwError <<< error <<< show <<< head <<< unwrap
