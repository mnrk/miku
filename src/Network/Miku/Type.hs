{-# LANGUAGE TemplateHaskell #-}

module Network.Miku.Type where

import Control.Monad.Reader
import Control.Monad.State
import Data.Default
import Hack2
import Hack2.Contrib.Utils
import Data.ByteString.Lazy.Char8 (ByteString)

import Air.TH

type AppReader    = Env
type AppState     = Response
type AppMonadT    = ReaderT AppReader (StateT AppState IO)
type AppMonad     = AppMonadT ()


data MikuState = MikuState
  {
    middlewares     :: [Middleware]
  , mimes           :: [(ByteString, ByteString)]
  }


instance Default MikuState where
  def = MikuState 
    {
      middlewares = def
    , mimes = def
    }

mkLabel ''MikuState

type MikuMonadT a = State MikuState a
type MikuMonad    = MikuMonadT ()
