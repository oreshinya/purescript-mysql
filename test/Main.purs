module Test.Main where

import Prelude

import Control.Monad.Error.Class (throwError)
import Data.Either (isLeft)
import Data.Maybe (Maybe(..))
import Data.Unfoldable (replicateA)
import Effect (Effect)
import Effect.Aff (attempt)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import MySQL.Connection (defaultConnectionInfo, execute, format, query)
import MySQL.Pool (Pool, closePool, createPool, defaultPoolInfo, withPool)
import MySQL.QueryValue (match, toQueryValue)
import MySQL.Transaction (withTransaction)
import Simple.ULID (genULID, toString)
import Simple.ULID.Node (prng)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (run, runTestWith)
import Test.Unit.Output.Fancy (runTest)

type User =
  { id :: String
  , name :: String
  }

main :: Effect Unit
main = run do
  pool <- liftEffect createPool'

  runTestWith runTest do
    test "match" do
      let x = toQueryValue [ [ toQueryValue 1, toQueryValue $ Just "2" ] ]
      Assert.assert "Expected: same, Gotten: not same" $ match x x
      Assert.assert "Expected: not same, Gotten: same" $ not $ match x
        $ toQueryValue [ [ toQueryValue 1, toQueryValue $ Just "2" ] ]
    test "Format" do
      formated <- flip withPool pool
        $ liftEffect <<< format "SELECT * FROM users WHERE id = ?" [ toQueryValue "dummyId" ]
      Assert.equal "SELECT * FROM users WHERE id = 'dummyId'" formated

    test "Queries" do
      flip withPool pool \conn -> do
        userId <- liftEffect $ genULID prng <#> toString
        let userName = "dummy_name_" <> userId
        execute
          "INSERT INTO users (id, name) VALUES (?, ?)"
          [ toQueryValue userId, toQueryValue userName ]
          conn
        users <- query
          "SELECT * FROM users WHERE id = ?"
          [ toQueryValue userId ]
          conn
        Assert.equal
          [ { id: userId, name: userName } ]
          users

    suite "Transaction" do
      test "Commit" do
        flip withPool pool \conn -> do
          xs <- liftEffect $ replicateA 2
            $ genULID prng <#> toString <#> \id -> { id, name: "dummy_name_" <> id }
          flip withTransaction conn $ execute
            "INSERT INTO users (id, name) VALUES ?"
            [ toQueryValue $ (xs <#> \x -> [ x.id, x.name ]) ]
          users <- query
            "SELECT * FROM users WHERE id IN (?) ORDER BY FIELD(id, ?)"
            [ toQueryValue $ xs <#> _.id, toQueryValue $ xs <#> _.id ]
            conn
          Assert.equal xs users

      test "Rollback" do
        flip withPool pool \conn -> do
          (xs :: Array User) <- liftEffect $ replicateA 2
            $ genULID prng <#> toString <#> \id -> { id, name: "dummy_name_" <> id }
          result <- attempt $ flip withTransaction conn \conn' -> do
            execute
              "INSERT INTO users (id, name) VALUES ?"
              [ toQueryValue $ (xs <#> \x -> [ toQueryValue x.id, toQueryValue x.name ]) ]
              conn'
            throwError $ error "Rollback Test"
          Assert.assert "Error was ignored" $ isLeft result
          users <- query
            "SELECT * FROM users WHERE id IN (?) ORDER BY FIELD(id, ?)"
            [ toQueryValue $ xs <#> _.id, toQueryValue $ xs <#> _.id ]
            conn
          Assert.equal ([] :: Array User) users

  liftEffect $ closePool pool

createPool' :: Effect Pool
createPool' = createPool connInfo defaultPoolInfo
  where
    connInfo = defaultConnectionInfo
      { host = "127.0.0.1"
      , database = "purescript_mysql"
      }
