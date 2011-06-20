{-# LANGUAGE OverloadedStrings #-}


module Network.Miku.Config where

import Hack2
import Hack2.Contrib.Middleware.Config
import Hack2.Contrib.Middleware.ContentLength
import Hack2.Contrib.Middleware.ContentType
import Network.Miku.Utils
import Prelude hiding ((.), (>), (^), (-))
import Data.ByteString.Char8 (ByteString)


pre_installed_middlewares :: [Middleware]
pre_installed_middlewares = 
  [
    content_length
  , content_type default_content_type
  ]
  where
    default_content_type = "text/plain; charset=UTF-8"


miku_captures :: ByteString
miku_captures = "miku-captures-"