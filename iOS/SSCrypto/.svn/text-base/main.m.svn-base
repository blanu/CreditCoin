#import <Foundation/Foundation.h>
#import "SSCrypto.h"

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	SSCrypto *crypto;
	int n;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// TEST 1: Get SHA1 and MD5 digest for string
	
	// This is the same as running the following command in the terminal:
	// echo -n "foo" | openssl dgst -sha1
	// echo -n "foo" | openssl dgst -md5
	
	NSString *name = @"foo";
	
	crypto = [[SSCrypto alloc] init];
	[crypto setClearTextWithString:name];
	
	NSLog(@"Name: %@", [crypto clearTextAsString]);
	
	NSLog(@"SHA1 Digest of Name using digest method: %@", [[crypto digest:@"SHA1"] hexval]);
	
	NSData *sha1Name = [SSCrypto getSHA1ForData:[name dataUsingEncoding:NSUTF8StringEncoding]];
	NSLog(@"SHA1 Digest using getSHA1ForData method: %@", [sha1Name hexval]);
	
	NSLog(@"MD5 Digest of Name using digest method: %@", [[crypto digest:@"MD5"] hexval]);
	
	NSData *md5Name = [SSCrypto getMD5ForData:[name dataUsingEncoding:NSUTF8StringEncoding]];
	NSLog(@"MD5 Digest using getMD5ForData method : %@", [md5Name hexval]);
	
	NSLog(@" ");
	NSLog(@" ");
	NSLog(@" ");
	
    [crypto release];

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Test 2: Symmetric encryption and decryption using various ciphers
	
	NSData *seedData1 = [SSCrypto getKeyDataWithLength:32];
	crypto = [[SSCrypto alloc] initWithSymmetricKey:seedData1];
	
	NSArray *ciphers = [NSArray arrayWithObjects:@"aes256", @"aes128", @"blowfish", @"aes192",
		@"RC4", @"blowfish", @"RC5", @"des3", @"des", nil];
	
	NSString *password = @"pumpkin";
	[crypto setClearTextWithString:password];
	
	for(n = 0; n < [ciphers count]; n++)
	{
		NSData *cipherText = [crypto encrypt:[ciphers objectAtIndex:n]];
		NSData *clearText = [crypto decrypt:[ciphers objectAtIndex:n]];
        NSData *base64 = [NSData dataWithBytes:[[clearText encodeBase64WithNewlines:NO] UTF8String] length:[[clearText encodeBase64WithNewlines:NO] length]];

		NSLog(@"Original password: %@", password);
		NSLog(@"Original password base64 encoded: %s", [base64 bytes]);
		NSLog(@"Original password base64 decoded: %s", [[base64 decodeBase64WithNewLines:NO] bytes]);
		NSLog(@"Cipher text: '%@' using %@", [cipherText encodeBase64WithNewlines:NO], [ciphers objectAtIndex:n]);
		NSLog(@"Clear text: '%s' using %@", [clearText bytes], [ciphers objectAtIndex:n]);

		NSLog(@" ");
	}

	NSLog(@" ");
	NSLog(@" ");

    for(n = 0; n < [ciphers count]; n++)
	{
		NSData *cipherText = [crypto encrypt:[ciphers objectAtIndex:n] withSalt:TRUE];
		NSData *clearText = [crypto decrypt:[ciphers objectAtIndex:n]];
        NSData *base64 = [NSData dataWithBytes:[[clearText encodeBase64WithNewlines:NO] UTF8String] length:[[clearText encodeBase64WithNewlines:NO] length]];
        
		NSLog(@"Original password: %@", password);
		NSLog(@"Original password base64 encoded: %s", [base64 bytes]);
		NSLog(@"Original password base64 decoded: %s", [[base64 decodeBase64WithNewLines:NO] bytes]);
		NSLog(@"Cipher text (salted): '%@' using %@", [cipherText hexval], [ciphers objectAtIndex:n]);
		NSLog(@"Cipher text b64 (salted): '%@' using %@", [cipherText encodeBase64WithNewlines:NO], [ciphers objectAtIndex:n]);
		NSLog(@"Clear text: '%s' using %@", [clearText bytes], [ciphers objectAtIndex:n]);
        
		NSLog(@" ");
	}
    
	NSLog(@" ");
	NSLog(@" ");
    
	[crypto release];
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Test 3: Generating digests from strings
	
	// This is the same as running the following command in the terminal:
	// echo -n "I like cheese" | openssl dgst -md5
	//
	// Where -md5 is the digest to use.
	// See man dgst for a list of all available digests.
	
	crypto = [[SSCrypto alloc] init];
	
	NSArray *digests = [NSArray arrayWithObjects:@"MD4", @"MD5", @"SHA1", @"RIPEMD160", nil];
	
	NSString *secret = @"I like cheese";
    [crypto setClearTextWithString:secret];
	
	for(n = 0; n < [digests count]; n++)
	{
		NSData *digest = [crypto digest:[digests objectAtIndex:n]];
		NSLog(@"'%@' %@ digest hexdump: %@", [crypto clearTextAsString], [digests objectAtIndex:n], [digest hexval]);
	}
	
	NSLog(@" ");
	NSLog(@" ");
	NSLog(@" ");
	
	[crypto release];
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Generate public and private key for next 2 tests...

	// You can generate your own private key by running the following command in the terminal:
	// openssl genrsa -out private.pem 2048
	//
	// Where 2048 is the size of the private key.
	// You may used a bigger number.
	// It is probably a good recommendation to use at least 1024...

	// Then to extract the public key from the private key, use the following command:
	// openssl rsa -in private.pem -out public.pem -outform PEM -pubout
	
	// If you are unfamiliar with the basics of Public-key cryptography, a great tutorial can be found on wikipedia:
	// http://en.wikipedia.org/wiki/Public-key_cryptography

    // generate a private key
    NSData *privateKeyData = [SSCrypto generateRSAPrivateKeyWithLength:2048];
    NSLog(@"privateKeyData: \n%s", [privateKeyData bytes]);
    // generate a public key from the private key data
    NSData *publicKeyData = [SSCrypto generateRSAPublicKeyFromPrivateKey:privateKeyData];
    NSLog(@"publicKeyData: \n%s", [publicKeyData bytes]);

    // At this point you would write the private and public keys to files
    // for later use like so:
    //
    // [privateKeyData writeToFile:@"/some/file/path/private.pem" atomically:YES];
    // [publicKeyData writeToFile:@"/some/file/path/public.pem" atomically:YES];

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Test 4: Sign (encrypt), and then verify (decrypt) a string
	
	// Signing is the same as running the following command in the terminal:
	// echo -n "The duck quacks at daybreak" | openssl rsautl -sign -inkey Privatekey.pem | openssl enc -base64
	
	// Verifying is the same as running the following command in the terminal:
	// echo -n "Q102..." | openssl enc -base64 -d | openssl rasutl -verify -inkey PUBKEY.pem -pubin
	
	crypto = [[SSCrypto alloc] initWithPublicKey:publicKeyData privateKey:privateKeyData];
	
	NSString *secretPhrase = @"The duck quacks at daybreak";
	[crypto setClearTextWithString:secretPhrase];
	
	NSData *signedTextData = [crypto sign];
	NSData *verifiedTextData = [crypto verify];
	
	NSLog(@"Secret Phrase: %@", secretPhrase);
	NSLog(@"Signed (Encrypted using private key): %@", [signedTextData encodeBase64]);
	NSLog(@"Verified (Decrypted using public key): %s", [verifiedTextData bytes]);
	
	// Note: we could also have output the verifiedTextData (clearText) by doing the following:
	// NSLog(@"Now Verified: %@", [crypto clearTextAsString]);
	
	NSLog(@" ");
	NSLog(@" ");
	NSLog(@" ");
	
	[crypto release];
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Test 5: Encrypt, and then decrypt a string
	
	// Encrypting is the same as running the following command in the terminal:
	// echo -n "Billy likes Mandy" | openssl rsautl -encrypt -inkey PUBKEY.pem -pubin | openssl enc -base64
	// 
	// Note: you'll get a different encryption everytime, so don't expect them to be the same...
	
	// Decrypting is the same as running the following command in the terminal:
	// echo -n "SLSbd6..."| openssl enc -base64 -d | openssl rsautl -decrypt -inkey Privatekey.pem
	
	crypto = [[SSCrypto alloc] initWithPublicKey:publicKeyData privateKey:privateKeyData];
	
	NSString *topSecret = @"Billy likes Mandy";
	[crypto setClearTextWithString:topSecret];
	
	NSData *encryptedTextData = [crypto encrypt];
	NSData *decryptedTextData = [crypto decrypt];

	NSLog(@"Top Secret: %@", topSecret);
	NSLog(@"Encrypted: %@", [encryptedTextData encodeBase64]);
	NSLog(@"Decrypted: %s", [decryptedTextData bytes]);
	
	// Note: we could also have output the decryptedTextData (clearText) by doing the following:
	// NSLog(@"Now Decrypted: %@", [crypto clearTextAsString]);
	
	NSLog(@" ");
	NSLog(@" ");
	NSLog(@" ");

	[crypto release];
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Test 6: PBKDF2
    
    NSString *password2 = @"password2";
    NSString *salt = @"this is a salt";

    NSData *key = [SSCrypto getKeyDataWithLength:256 fromPassword:password2 withSalt:salt withIterations:24];
    NSLog(@"PBKDF2 Key: \n%@", [key encodeBase64]);

    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Test 7: Encrypt, and then decrypt a UTF8 string
	
	// Encrypting is the same as running the following command in the terminal:
	// cat moose.txt | openssl rsautl -encrypt -inkey PUBKEY.pem -pubin | openssl enc -base64
	// 
	// Note: you'll get a different encryption everytime, so don't expect them to be the same...
	
	// Decrypting is the same as running the following command in the terminal:
	// echo -n "SLSbd6..."| openssl enc -base64 -d | openssl rsautl -decrypt -inkey Privatekey.pem

    NSString *moosePath = @"/Users/ed/Projects/SScrypto/moose.txt";
	if ([[NSFileManager defaultManager] fileExistsAtPath:moosePath]) {
        crypto = [[SSCrypto alloc] initWithPublicKey:publicKeyData privateKey:privateKeyData];
        
        NSError *err;
        topSecret = [NSString stringWithContentsOfFile:moosePath encoding:NSUTF8StringEncoding error:&err];
        if (!topSecret) {
            NSLog(@"error: %@", err);
        }
        [crypto setClearTextWithString:topSecret];
        
        encryptedTextData = [crypto encrypt];
        decryptedTextData = [crypto decrypt];
        
        NSLog(@"Top Secret: %@", topSecret);
        NSLog(@"Top Secret: %@", [[crypto clearTextAsData] hexval]);
        NSLog(@"Encrypted:\n%@", [encryptedTextData encodeBase64]);
        NSLog(@"Decrypted: %@", [decryptedTextData hexval]);
        NSLog(@"Decrypted: %@", [crypto clearTextAsString]);

        NSLog(@" ");
        NSLog(@" ");
        NSLog(@" ");
        
        [crypto release];
    }
    else {
        NSLog(@"where is moose.txt?!");
        NSLog(@"can't test the UTF-8 stuff without it...");

        NSLog(@" ");
        NSLog(@" ");
        NSLog(@" ");
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
	[pool release];
    return 0;
}
