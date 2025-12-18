Class {
	#name : 'PubNubSignalingContact',
	#superclass : 'SignalingContact',
	#instVars : [
		'subKey',
		'pubKey'
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
PubNubSignalingContact >> arrayBufferToBase64: buffer [

	<javascript: 'let binary = '''';
  const bytes = new Uint8Array(buffer);
  const len = bytes.byteLength;
  for (let i = 0; i < len; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);'>
	self error: 'should not be used'
]

{ #category : 'as yet unclassified' }
PubNubSignalingContact >> encodeAESnRSA: aJsonObject then: aBlock [

	(window crypto subtle
		 generateKey: {
				 (#name -> 'AES-GCM').
				 (#length -> 256) } asJsObject
		 extractable: true
		 purpose: { 'encrypt'. 'decrypt' } asJsObject) then: [ :key |
		| iv data |
		iv := window crypto getRandomValues: (self uint8Array: 12).
		data := TextEncoder new encode: (JSON stringify: aJsonObject).
		(window crypto subtle
			 encrypt: {
					 (#name -> 'AES-GCM').
					 (#iv -> iv) } asJsObject
			 key: key
			 data: data) then: [ :ciphertextBuffer |
			(window crypto subtle
				 wrapKey: 'raw'
				 aesKey: key
				 rsaKey: pubRSAKey
				 options: { (#name -> 'RSA-OAEP') } asJsObject) then: [
				:encryptedKey |
				aBlock
					value: (self arrayBufferToBase64: ciphertextBuffer)
					value: (self arrayBufferToBase64: encryptedKey)
					value: (self arrayBufferToBase64: iv) ] ] ]
]

{ #category : 'as yet unclassified' }
PubNubSignalingContact >> encodeRSA: encoded then: aBlock [

	(window crypto subtle
		 encrypt: { (#name -> 'RSA-OAEP') } asJsObject
		 key: pubRSAKey
		 encoded: encoded) then: [ :cipherBin |
		aBlock value: (self arrayBufferToBase64: cipherBin) ]
]

{ #category : 'as yet unclassified' }
PubNubSignalingContact >> handleAnswer: anAnswerMessage [

	announcer announce: (SignalingAnswerReceived new
			 answer: anAnswerMessage;
			 yourself)
]

{ #category : 'as yet unclassified' }
PubNubSignalingContact >> handleCandidate: anCandidateMessage [

	announcer announce: (SignalingCandidateReceived new
			 candidate: anCandidateMessage;
			 yourself)
]

{ #category : 'as yet unclassified' }
PubNubSignalingContact >> handleOffer: anOfferMessage [

	announcer announce: (SignalingOfferReceived new
			 offer: anOfferMessage;
			 yourself)
]

{ #category : 'as yet unclassified' }
PubNubSignalingContact >> ping [

	console log: originRSAKey.
	pubRSAKey
		ifNil: [
			(window crypto subtle exportKey: 'jwk' keys: originRSAKey) then: [
				:exportedKey |
				| postClient |
				postClient := XMLHttpRequest new.
				exportedKey at: #type put: #ping.
				postClient
					open: 'POST'
					url:
						'https://ps.pndsn.com/publish/' , pubKey , '/' , subKey , '/0/'
						, address , '/0?uuid=' , originAddress.
				postClient send: (JSON stringify: {
							 (#data -> exportedKey).
							 (#cyphered -> false) } asJsObject) ] ]
		ifNotNil: [
			(window crypto subtle exportKey: 'jwk' keys: originRSAKey) then: [
				:exportedKey |
				exportedKey at: #type put: #ping.
				self
					encodeAESnRSA: exportedKey asJsObject
					then: [ :encryptedData :encryptedKey :iv |
						| postClient |
						postClient := XMLHttpRequest new.
						postClient
							open: 'POST'
							url:
								'https://ps.pndsn.com/publish/' , pubKey , '/' , subKey
								, '/0/' , address , '/0?uuid=' , originAddress.
						postClient send: (JSON stringify: {
									 (#data -> encryptedData).
									 (#cyphered -> true).
									 (#key -> encryptedKey).
									 (#iv -> iv) } asJsObject) ] ] ]
]

{ #category : 'accessing' }
PubNubSignalingContact >> pubKey: anObject [

	pubKey := anObject
]

{ #category : 'accessing' }
PubNubSignalingContact >> send: aMessage [

	self
		encodeAESnRSA: aMessage
		then: [ :encryptedData :encryptedKey :iv |
			| postClient |
			postClient := XMLHttpRequest new.
			postClient
				open: 'POST'
				url:
					'https://ps.pndsn.com/publish/' , pubKey , '/' , subKey , '/0/'
					, address , '/0?uuid=' , originAddress.
			postClient send: (JSON stringify: {
						 (#data -> encryptedData).
						 (#cyphered -> true).
						 (#key -> encryptedKey).
						 (#iv -> iv) } asJsObject) ]
]

{ #category : 'accessing' }
PubNubSignalingContact >> subKey: anObject [

	subKey := anObject
]

{ #category : 'as yet unclassified' }
PubNubSignalingContact >> uint8Array: aNumber [
	<javascript: 'return new Uint8Array(aNumber)'>
]
