{-# LANGUAGE OverloadedStrings #-}

import Network.Miku
import Hack2.Handler.HappstackServer

main = do
  
  putStrLn "server started on port 3000..."
  
  run . miku $ get "/" (text "miku power")