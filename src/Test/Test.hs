{-# LANGUAGE PackageImports #-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Monad.Reader
import Hack2.Contrib.Response
-- import Hack2.Handler.SimpleServer
import Hack2.Handler.HappstackServer
import Hack2.Contrib.Utils (show_bytestring)

import Network.Miku
import Network.Miku.Engine
import Network.Miku.Utils
import Network.Miku.Middleware.MikuRouter
import Data.Maybe
import Air.Env hiding ((.))
import Prelude ((.))

import Hack2.Contrib.Request
import qualified Data.ByteString.Lazy.Char8 as B

import Hack2.Contrib.Middleware.SimpleAccessLogger



-- default on port 3000

main :: IO ()
main = do
  putStrLn "server started on port 3000..."
  
  run . miku - do
  
    
    before return
    after return

    middleware - simple_access_logger Nothing

    get "/bench" - do
      name <- ask ^ params ^ lookup "name" ^ fromMaybe "nobody"
      html ("<h1>" + name + "</h1>")

    -- on the fly router switcher
    router miku_router

    -- simple
    get "/hello"    (text "hello world")
  
    get "/debug"    (text . show_bytestring =<< ask)
  
    -- io
    get "/cabal"    - text =<< io (B.readFile "miku.cabal")

    -- route captures
    get "/say/:user/:message" - do
      text . show_bytestring =<< captures

    -- html output
    get "/html"     (html "<html><body><p>miku power!</p></body></html>")


  
    -- default
    get "/" - do
      io . print =<< ask ^ url
      text . show_bytestring =<< ask

    -- public serve, only allows /src
    public (Just ".") ["/src"]
  
    -- treat .hs extension as text/plain
    mime "hs" "text/plain"

