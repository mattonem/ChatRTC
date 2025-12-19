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
PubNubSignalingClient >> addContact: anotherAddress [

	| newContact |
	contacts
		at: anotherAddress
		put: (newContact := PubNubSignalingContact new
				               pubKey: pubKey;
				               subKey: subKey;
				               originAddress: address;
				               address: anotherAddress;
				               originRSAKey: publicRSAKey;
				               yourself).
	newContact ping.
	announcer announce: (SignalingNewContact new
			 contact: newContact;
			 yourself)
]

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> addContact: anotherAddress pubRSAKey: key [

	| newContact |
	contacts at: anotherAddress ifPresent: [ :aContact |
		aContact pubRSAKey: key.
		^ self ].
	contacts
		at: anotherAddress
		put: (newContact := PubNubSignalingContact new
				               pubKey: pubKey;
				               subKey: subKey;
				               originAddress: address;
				               address: anotherAddress;
				               originRSAKey: publicRSAKey;
				               pubRSAKey: key;
				               yourself).

	newContact ping.

	announcer announce: (SignalingNewContact new
			 contact: newContact;
			 yourself)
]

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

	announcer announce: SignalingStatus closed
	
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

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> generateNewKeys [

	| promKeys |
	promKeys := crypto subtle
		            generateKey: {
				            (#name -> 'RSA-OAEP').
				            (#modulusLength -> 4096).
				            (#publicExponent -> self publicExponent).
				            (#hash -> 'SHA-256') } asJsObject
		            extractable: true
		            usage: { #unwrapKey. #wrapKey } asJsObject.
	promKeys then: [ :genKeys |
		privateRSAKey := genKeys privateKey.
		publicRSAKey := genKeys publicKey.

		(crypto subtle exportKey: 'spki' key: publicRSAKey) then: [
			:exported |
			| hashBufferProm |
			hashBufferProm := crypto subtle digest: 'SHA-256' key: exported.
			hashBufferProm then: [ :hashBuffer |
				address := self toHex: hashBuffer.
				announcer announce: (SignalingAddressUpdated new address: address) ] ] ]
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
PubNubSignalingClient >> isOpen [

	^ listner isNotNil
]

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> open [

	| tt |
	listner ifNil: [
		listner := XMLHttpRequest new.
		listner onload: [ :aClient |
			| resp messages |
			resp := JSON parse: aClient currentTarget responseText.
			tt := resp t t.
			messages := resp m.
			messages do: [ :aMessage |
				aMessage d cyphered
					ifTrue: [
						self decodeAESnRSAMessage: aMessage d then: [ :data |
							(data jsHasOrInheritsProperty: #candidate)
								ifTrue: [ (contacts at: aMessage i) handleCandidate: data ]
								ifFalse: [
									data type = #ping ifTrue: [
										self importPublicKey: data then: [ :importedKey |
											self
												getAddressForPubKey: importedKey
												then: [ :anotherAddress |
													anotherAddress = aMessage i ifTrue: [
														self addContact: anotherAddress pubRSAKey: importedKey ] ] ] ].
									data type = #offer ifTrue: [
										(contacts at: aMessage i) handleOffer: data ].
									data type = #answer ifTrue: [
										(contacts at: aMessage i) handleAnswer: data ] ] ] ]
					ifFalse: [
						aMessage d data type = #ping ifTrue: [
							self importPublicKey: aMessage d data then: [ :importedKey |
								self
									getAddressForPubKey: importedKey
									then: [ :anotherAddress |
										anotherAddress = aMessage i ifTrue: [
											self addContact: anotherAddress pubRSAKey: importedKey ] ] ] ] ] ].

			announcer announce: SignalingStatus open.
			listner
				open: 'GET'
				url:
					'https://ps.pndsn.com/v2/subscribe/' , subKey , '/' , address
					, '/0?tt=' , tt , '&uuid=' , address.
			listner send ].
		listner
			open: 'GET'
			url: 'https://ps.pndsn.com/v2/subscribe/' , subKey , '/' , address
				, '/0?tt=0&uuid=' , address.
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

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> publicExponent [

	<javascript: 'return new Uint8Array([1, 0, 1]);'>
	^ self error: 'should not be used'
	
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
