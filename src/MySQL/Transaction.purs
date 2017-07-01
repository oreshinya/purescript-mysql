module MySQL.Transaction
  ( withTransaction
  ) where

import Prelude
import Control.Monad.Aff (Aff, Canceler, nonCanceler, attempt)
import Control.Monad.Error.Class (throwError)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn2, runFn2)
import MySQL (MYSQL)
import MySQL.Connection (Connection)



withTransaction :: forall e a.
                   (Connection -> Aff (mysql :: MYSQL | e) a) ->
                   Connection ->
                   Aff (mysql :: MYSQL | e) a
withTransaction handler conn = do
  begin conn
  r <- attempt $ handler conn
  case r of
    Left e -> do
      rollback conn
      throwError e
    Right r' -> do
      commit conn
      pure r'



begin :: forall e. Connection -> Aff (mysql :: MYSQL | e) Unit
begin = runFn2 _begin nonCanceler



commit :: forall e. Connection -> Aff (mysql :: MYSQL | e) Unit
commit = runFn2 _commit nonCanceler



rollback :: forall e. Connection -> Aff (mysql :: MYSQL | e) Unit
rollback = runFn2 _rollback nonCanceler



foreign import _begin :: forall e. Fn2 (Canceler (mysql :: MYSQL | e)) Connection (Aff (mysql :: MYSQL | e) Unit)



foreign import _commit :: forall e. Fn2 (Canceler (mysql :: MYSQL | e)) Connection (Aff (mysql :: MYSQL | e) Unit)



foreign import _rollback :: forall e. Fn2 (Canceler (mysql :: MYSQL | e)) Connection (Aff (mysql :: MYSQL | e) Unit)
