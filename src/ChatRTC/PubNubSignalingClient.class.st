Class {
	#name : 'PubNubSignalingClient',
	#superclass : 'SignalingClient',
	#instVars : [
		'listner',
		'pubKey',
		'subKey'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> close [ 
	listner ifNotNil: [ listner abort ].
	listner := nil.

	announcer announce: SignalingStatus closed
	
]

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> isOpen [

	^ listner isNotNil
]

{ #category : 'as yet unclassified' }
PubNubSignalingClient >> newContactAddress: anotherAddress pubRSAKey: key [

	^ PubNubSignalingContact new
		  pubKey: pubKey;
		  subKey: subKey;
		  originAddress: address;
		  address: anotherAddress;
		  originRSAKey: publicRSAKey;
		  pubRSAKey: key;
		  yourself
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
			messages do: [ :aMessage | self handleMessage: aMessage ].

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

{ #category : 'accessing' }
PubNubSignalingClient >> subKey [

	^ subKey
]

{ #category : 'accessing' }
PubNubSignalingClient >> subKey: anObject [

	subKey := anObject
]
