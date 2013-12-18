import Data.Serialize
import Crypto.Threefish.Random

import Dust.Crypto.ECDSA

import CreditCoin.Joss.Price

main :: IO()
main = do
  maybePrice <- fetchPrice
  case maybePrice of
    Just price -> putStrLn $ show $ stamp price
    Nothing    -> putStrLn "Error"
  
stamp :: Float -> Signedtext
stamp price = do
  let prng = newSkeinGen
  let (rand, prng') = randomBytes 32 prng
  let (Keypair pub priv) = createSigningKeypair rand
  let bytes = encode price
  let signed = sign bytes pub
  return signed
