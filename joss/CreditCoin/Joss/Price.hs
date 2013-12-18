module CreditCoin.Joss.Price
(
  fetchPrice
)
where

import System.IO
import qualified Data.ByteString as B
import Data.ByteString.Lazy.Char8 (pack)
import System.Environment (getArgs)
import Network.HTTP
import Data.Aeson as DA
import Data.HashMap.Strict as M
import qualified Data.Text as DT

fetchPrice :: IO (Maybe Float)
fetchPrice = do
    let url = "http://api.bitcoincharts.com/v1/weighted_prices.json"
    result <- fetch url
    let maybePrices = decode (pack result) :: Maybe Object
    case maybePrices of
      Just prices -> do
        let maybeUsd = M.lookup (DT.pack "USD") prices
        case maybeUsd of
          Just usdv -> do
            case usdv of
              usd@(Object o) -> do
                let maybeUsd24 = M.lookup (DT.pack "24h") o
                case maybeUsd24 of
                  Just usd24 -> do
                    case usd24 of
                      DA.String text -> do
                        let f = (read $ DT.unpack text) :: Float
                        return $ Just f
                      otherwise   -> return Nothing
                  Nothing    -> return Nothing
              otherwise -> do
                return Nothing
          Nothing -> do
            return Nothing
      Nothing -> do
        return Nothing

fetch :: String -> IO String
fetch url = do
  request <- simpleHTTP (getRequest url)
  response <- getResponseBody request
  return (response)
