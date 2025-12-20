Class {
	#name : 'PubNubSignalingContact',
	#superclass : 'SignalingContact',
	#instVars : [
		'subKey',
		'pubKey'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'as yet unclassified' }
PubNubSignalingContact >> postMessage: anObject [

	| postClient |
	postClient := XMLHttpRequest new.
	postClient
		open: 'POST'
		url:
			'https://ps.pndsn.com/publish/' , pubKey , '/' , subKey , '/0/'
			, address , '/0?uuid=' , originAddress.
	^ postClient send: (JSON stringify: anObject)
]

{ #category : 'accessing' }
PubNubSignalingContact >> pubKey: anObject [

	pubKey := anObject.
]

{ #category : 'accessing' }
PubNubSignalingContact >> subKey: anObject [

	subKey := anObject
]
