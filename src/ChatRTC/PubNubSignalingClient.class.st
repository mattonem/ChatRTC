Class {
	#name : 'PubNubSignalingClient',
	#superclass : 'SignalingClient',
	#instVars : [
		'listner',
		'pubKey',
		'subKey'
	],
	#pools : [
		'PjDomGlobals',
		'PjUniversalGlobals',
		'RTCGlobals'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> base64ToArrayBuffer: base64 [

	<javascript: 'const binaryString = window.atob(base64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;'>
	self error: 'should not be used'
]

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> close [ 

	listner ifNotNil: [ listner abort ].
	listner := nil.
	self isClosed.
]

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> decodeAESnRSAMessage: message then: aBlock [

	| encryptedKeyBuffer ivBuffer ciphertextBuffer |
	encryptedKeyBuffer := self base64ToArrayBuffer: message key.
	ivBuffer := self base64ToArrayBuffer: message iv.
	ciphertextBuffer := self base64ToArrayBuffer: message data.

	(window crypto subtle
		 unwrapKey: 'raw'
		 keyBuffer: encryptedKeyBuffer
		 privateKey: privateRSAKey
		 wrapAlgo: { (#name -> 'RSA-OAEP') } asJsObject
		 targetAlgo: { (#name -> 'AES-GCM') } asJsObject
		 extractable: true
		 purpose: { 'decrypt' }) then: [ :aesKey |
		(window crypto subtle
			 decrypt: {
					 (#name -> 'AES-GCM').
					 (#iv -> ivBuffer) } asJsObject
			 key: aesKey
			 buffer: ciphertextBuffer) then: [ :decryptedBuffer |
			| decodedString |
			decodedString := TextDecoder new decode: decryptedBuffer.
			aBlock value: (JSON parse: decodedString) ] ]
]

{ #category : 'accessing' }
PubNubSignalingClient >> getAddressForPubKey: aKey then: aBlock [

	| promExpKey |
	promExpKey := crypto subtle exportKey: 'spki' key: aKey.
	promExpKey then: [ :exported |
		| hashBufferProm |
		hashBufferProm := crypto subtle digest: 'SHA-256' key: exported.
		hashBufferProm then: [ :hashBuffer |
			| address |
			address := self toHex: hashBuffer.
			aBlock value: address ] ]
]

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> importPublicKey: jwk then: aBlock [

	(window crypto subtle
		 importKey: 'jwk'
		 key: jwk
		 options: {
				 (#name -> 'RSA-OAEP').
				 (#hash -> 'SHA-256') } asJsObject
		 extractable: true
		 usage: { #wrapKey } asJsObject) then: aBlock
]

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> openOn: anAddress [

	| tt |
	listner ifNil: [
		listner := XMLHttpRequest new.
		listner onload: [ :aClient |
			| resp messages |
			resp := JSON parse: aClient currentTarget responseText.
			tt := resp t t.
			messages := resp m.
			self isOpen.
			messages do: [ :aMessage |
				aMessage d cyphered
					ifTrue: [
						self decodeAESnRSAMessage: aMessage d then: [ :data |
							self importPublicKey: data then: [ :importedKey |
								self
									getAddressForPubKey: importedKey
									then: [ :anotherAddress |
										anotherAddress = aMessage i ifTrue: [
											announcer announce: (SignalingSercuredPing new
													 address: anotherAddress;
													 pubRSAKey: importedKey;
													 yourself) ] ] ] ] ]
					ifFalse: [
						self importPublicKey: aMessage d data then: [ :importedKey |
							self
								getAddressForPubKey: importedKey
								then: [ :anotherAddress |
									anotherAddress = aMessage i ifTrue: [
										announcer announce: (SignalingUnsercuredPing new
												 address: anotherAddress;
												 pubRSAKey: importedKey;
												 yourself) ] ] ] ] ].
			listner
				open: 'GET'
				url:
					'https://ps.pndsn.com/v2/subscribe/' , subKey , '/' , anAddress
					, '/0?tt=' , tt , '&uuid=' , anAddress.
			listner send ].
		listner
			open: 'GET'
			url:
				'https://ps.pndsn.com/v2/subscribe/' , subKey , '/' , anAddress
				, '/0?tt=0&uuid=' , anAddress.
		listner send ]
]

{ #category : 'accessing' }
PubNubSignalingClient >> postCopy [

	super postCopy.
	listner := nil
]

{ #category : 'accessing' }
PubNubSignalingClient >> pubKey [

	^ pubKey
]

{ #category : 'accessing' }
PubNubSignalingClient >> pubKey: anObject [

	pubKey := anObject
]

{ #category : 'accessing' }
PubNubSignalingClient >> subKey [

	^ subKey
]

{ #category : 'accessing' }
PubNubSignalingClient >> subKey: anObject [

	subKey := anObject
]

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> toHex: something [

	<javascript:
	'const hashArray = Array.from(new Uint8Array(something)); // convert buffer to byte array
    const hashHex = hashArray
    .map((b) => b.toString(16).padStart(2, "0"))
    .join(""); // convert bytes to hex string
  return hashHex;'>
	^ self error: 'should not be used'
]
