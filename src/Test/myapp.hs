{-# LANGUAGE OverloadedStrings #-}

import Network.Miku
import Hack2.Handler.HappstackServer

main = run . miku $ get "/" (text "miku power")