{-# LANGUAGE OverloadedStrings #-}


import qualified Network.Miku as Miku
import Network.Miku (get, miku)
import Hack2.Handler.HappstackServer
import Text.HTML.Moe2

import Prelude hiding ((/), (-), head, (>), div)
import Air.Env ((-))

import Data.ByteString.Lazy.Char8 (ByteString, fromChunks)

hello_page :: ByteString
hello_page = render_bytestring -
  html - do
    head - do
      meta ! [http_equiv "Content-Type", content "text/html; charset=utf-8"] - (/)
      title - str "my title"

    body - do
      div ! [_class "container"] - do
        str "hello world"
        
        
main = do
  putStrLn - "server started..."
  
  run - miku - do
    get "/" - do
      Miku.html - hello_page